# Meraki Network as Code - Simple Example

This repository contains a simple example of how to use Network as Code to manage Meraki cloud-managed networks. This example demonstrates basic network configuration including wireless SSIDs, security appliance VLANs, default values, and reusable configuration templates.

## Prerequisites

- [Terraform 1.8.0 or later](https://www.terraform.io/downloads) (or OpenTofu)
- The [`nac` CLI](https://netascode.cisco.com/docs/tools/nac/installation/) (wraps Terraform, `nac-validate` and `nac-test`)
- [Git](https://github.com/git-guides/install-git)
- A Meraki Dashboard account with API access enabled
- A Meraki API key (generated from Dashboard > Organization > Settings > Dashboard API access)

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/netascode/nac-meraki-simple-example.git
   cd nac-meraki-simple-example
   ```

2. **Configure authentication:**
   
Set environment variables:
   ```bash
   export MERAKI_API_KEY="your-api-key-here"
   ```

3. **Update configuration:**
   
   Edit `data/networks.nac.yaml` and replace the placeholder values:
   - `cisco.com` → your domain
   - `admin@cisco.com` → your admin email
   - `Demo Organization` → your organization name

4. **Run the workflow with the `nac` CLI:**
   ```bash
   nac setup      # check prerequisites, env vars and tool versions
   nac init       # terraform init
   nac validate   # render the data model and run nac-validate
   nac plan
   nac apply
   nac test       # run nac-test against the rendered model
   ```

   The `nac` settings (render target, `model.yaml` output, required
   `MERAKI_API_KEY`, tested `nac-validate`/`nac-test` versions) come from the
   module's `nac/manifest.yaml`, so no `nac.yaml` is required. `nac setup` lists
   the settings taken from the module (available after `nac init`).

5. **(Optional) Override the module defaults with a `nac.yaml`:**
   ```bash
   cp nac.yaml.example nac.yaml
   ```
   Edit `nac.yaml` to pin tool versions, switch between `terraform` and `tofu`,
   change the render output, or replace the required environment variables.
   Settings in `nac.yaml` win key by key over the module defaults, and an
   explicit `null` (e.g. `render: null`) turns a module default off. `nac.yaml`
   is git-ignored here; see the
   [configuration reference](https://netascode.cisco.com/docs/tools/nac/configuration/).

   <details>
   <summary>Plain Terraform still works</summary>

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
   </details>

## Configuration Structure

```
nac-meraki-simple-example/
├── data/
│   ├── networks.nac.yaml    # Fully-defined example network
│   ├── templates.nac.yaml   # Reusable "branch_baseline" template
│   └── branches.nac.yaml    # Two branches built from the template
├── defaults/
│   └── defaults_override.nac.yaml    # Organization-wide defaults
├── main.tf                  # Main Terraform module
├── nac.yaml.example         # Optional nac CLI overrides (copy to nac.yaml)
└── README.md               # This file
```

## What This Example Creates

- A network named "Branch-Office-Demo" with support for all Meraki product types
- Two wireless SSIDs:
  - **Corporate-WiFi**: WPA2-PSK authentication with VLAN tagging
  - **Guest-WiFi**: Open authentication with captive portal
- RF profile for wireless optimization
- Two VLANs on the security appliance:
  - **Data VLAN** (100): 10.1.100.0/24 
  - **Voice VLAN** (200): 10.1.200.0/24
- Organization-wide default settings for wireless, switch, and appliance
- Two additional branches (**Rome-Branch-01**, **Lisbon-Branch-01**) generated from a shared template, each with its own subnets, gateways, and corporate SSID

## Configuration Files

### networks.nac.yaml

Contains the main network configuration with the correct YAML structure:
- Uses `meraki.domains.organizations` hierarchy
- Includes complete `product_types` array
- Uses proper field names (`ssid_number`, `vlan_id`)
- Matches validated test fixture format

### defaults/defaults_override.nac.yaml

Defines organization-wide defaults that apply to all networks:
- Wireless SSID defaults (enabled, IP assignment mode)
- Switch settings (power management, uplink sampling)
- Appliance firewall rules

### templates.nac.yaml and branches.nac.yaml

These two files show how to scale a consistent branch design across many sites
using **configuration templates**.

- **`templates.nac.yaml`** defines a reusable template named `branch_baseline`
  under `meraki.templates.networks`. It describes a complete branch — product
  types, VLANs, and SSIDs — once, using `${placeholder}` values for the parts
  that differ per site.
- **`branches.nac.yaml`** defines two networks (`Rome-Branch-01` and
  `Lisbon-Branch-01`) that reference the template with `templates: [branch_baseline]`
  and supply their own values through a `variables:` map.

Adding a new branch is a copy-paste of a short variable block, not the whole
network definition. And because the shared design lives in one place, changing
the template — for example updating a VLAN or an SSID setting — propagates to
every branch that uses it, keeping sites consistent and free of drift.

## Security Best Practices

- Never commit API keys to version control
- Use `terraform.tfvars` (excluded by .gitignore) or environment variables
- Follow principle of least privilege for API key permissions
- Regularly rotate API keys

## Cleanup

To remove all created resources:
```bash
terraform destroy
```

## Next Steps

This simple example can be extended to include:
- Multiple organizations and networks
- Advanced wireless features (splash pages, access control)
- Switch port configurations and VLAN assignments
- Security appliance firewall rules and VPN settings
- Device-specific configurations and templates

For more advanced examples and complete documentation, visit the [netascode.cisco.com](https://netascode.cisco.com) documentation portal.

## Support

- For issues with the nac-meraki module: [GitHub Issues](https://github.com/netascode/terraform-meraki-nac-meraki/issues)
- For Terraform provider issues: [Cisco DevNet](https://github.com/CiscoDevNet/terraform-provider-meraki)
- For professional services: Contact Cisco CX Professional Services
