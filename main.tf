terraform {
  required_providers {
    meraki = {
      source  = "CiscoDevNet/meraki"
      version = ">= 1.9.0"
    }
  }
}

provider "meraki" {}

module "meraki" {
  source  = "netascode/nac-meraki/meraki"
  version = "0.6.0"

  yaml_directories = ["data", "defaults"]
}
