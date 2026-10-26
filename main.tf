module "meraki" {
  source = "netascode/nac-meraki/meraki"

  yaml_directories = ["data"]
  model            = var.enable_netbox ? local.netbox_model : {} # optional NetBox overlay, see netbox.tf
}
