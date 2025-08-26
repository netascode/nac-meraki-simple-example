module "meraki" {
  source  = "netascode/nac-meraki/meraki"
  version = "0.3.3"

  yaml_directories = ["data", "defaults"]
  write_model_file = "./merged_defaults.yaml"
}