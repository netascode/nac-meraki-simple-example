# Retrieves addressing for each branch from NetBox (read-only data sources) and
# turns it into a `model` overlay that the NaC module deep-merges over data/*.yaml.
terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "5.8.0"
    }
  }
}

variable "netbox_url" {
  description = "NetBox base URL, e.g. https://netbox.example.com"
  type        = string
}

variable "netbox_token" {
  description = "NetBox API token (read-only is sufficient). Set via TF_VAR_netbox_token."
  type        = string
  sensitive   = true
}

provider "netbox" {
  server_url = var.netbox_url
  api_token  = var.netbox_token
}

locals {
  # NaC network name => NetBox site name and MX device name.
  branches = {
    "Rome-Branch-01"   = { site = "Rome Branch 01", device = "mx-rome-01" }
    "Lisbon-Branch-01" = { site = "Lisbon Branch 01", device = "mx-lisbon-01" }
  }

  # Template variable prefix => VLAN ID (matches templates.nac.yaml).
  vlans = { data = 100, voice = 200 }

  branch_vlans = merge([
    for net, b in local.branches : {
      for name, vid in local.vlans : "${net}/${name}" => {
        network = net, name = name, vid = vid, site = b.site, device = b.device
      }
    }
  ]...)
}

data "netbox_site" "branch" {
  for_each = local.branches
  name     = each.value.site
}

data "netbox_devices" "mx" {
  for_each = local.branches
  filter {
    name  = "name"
    value = each.value.device
  }
  lifecycle {
    postcondition {
      condition     = length(self.devices) == 1
      error_message = "Expected exactly 1 NetBox device named ${each.value.device}, found ${length(self.devices)}."
    }
  }
}

# Errors on zero or multiple matches for (site, VLAN ID).
data "netbox_prefix" "vlan" {
  for_each = local.branch_vlans
  site_id  = data.netbox_site.branch[each.value.network].id
  vlan_vid = each.value.vid
  status   = "active"
}

# The MX's address inside each VLAN prefix: exactly one is required.
data "netbox_ip_addresses" "gateway" {
  for_each = local.branch_vlans
  filter {
    name  = "device_id"
    value = data.netbox_devices.mx[each.value.network].devices[0].device_id
  }
  filter {
    name  = "parent_prefix"
    value = data.netbox_prefix.vlan[each.key].prefix
  }
  lifecycle {
    postcondition {
      condition     = length(self.ip_addresses) == 1
      error_message = "Expected exactly 1 IP for ${each.value.device} in ${each.value.name} prefix, found ${length(self.ip_addresses)}."
    }
  }
}

locals {
  # Overlay merged by the module over data/*.yaml; supplies the template variables.
  netbox_model = {
    meraki = { domains = [{
      name = "cisco.com"
      organizations = [{
        name = "Demo Organization"
        networks = [
          for net, b in local.branches : {
            name = net
            variables = merge([
              for name, vid in local.vlans : {
                "${name}_subnet"  = data.netbox_prefix.vlan["${net}/${name}"].prefix
                "${name}_gateway" = split("/", data.netbox_ip_addresses.gateway["${net}/${name}"].ip_addresses[0].ip_address)[0]
              }
            ]...)
          }
        ]
      }]
    }] }
  }
}
