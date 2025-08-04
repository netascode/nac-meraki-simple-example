module "meraki" {
  source  = "netascode/nac-meraki/meraki"
  version = "0.3.2"

  yaml_directories = ["data"]
}