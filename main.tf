module "meraki" {
  source  = "netascode/nac-meraki/meraki"

  yaml_directories = ["data"]
}
