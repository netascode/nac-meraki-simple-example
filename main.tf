terraform {
  required_version = ">= 1.9"
  required_providers {
    meraki = {
      source  = "CiscoDevNet/meraki"
      version = ">= 1.6.0"
    }
  }
}

module "meraki" {
  source  = "netascode/nac-meraki/meraki"
  version = "0.3.2"

  yaml_directories = ["data"]
}
