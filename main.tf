module "meraki" {
  source  = "netascode/nac-meraki/meraki"

  yaml_directories = ["data"]
  model            = local.netbox_model # addressing from NetBox, see netbox.tf
}
