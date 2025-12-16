module "meraki" {
  source  = "netascode/nac-meraki/meraki"
  version = "0.6.0"

  yaml_directories = ["data"]
}
