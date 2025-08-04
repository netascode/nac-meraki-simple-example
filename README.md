# Meraki Network as Code - Simple Example

This repository contains a simple example of how to use Network as Code to manage Meraki cloud-managed networks. This example demonstrates basic network configuration including wireless SSIDs, security appliance VLANs, and default values.

## Prerequisites

- [Terraform 1.8.0 or later](https://www.terraform.io/downloads)
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
   
   Copy the example variables file and update with your credentials:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` and add your API key:
   ```hcl
   meraki_api_key = "your-actual-api-key-here"
   ```

   Alternatively, set environment variables:
   ```bash
   export MERAKI_API_KEY="your-api-key-here"
   ```

3. **Update configuration:**
   
   Edit `data/networks.nac.yaml` and replace the placeholder values:
   - `cisco.com` → your domain
   - `admin@cisco.com` → your admin email
   - `Demo Organization` → your organization name

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Structure

```
nac-meraki-simple-example/
├── data/
│   ├── networks.nac.yaml    # Network and device configuration
│   └── defaults.nac.yaml    # Organization-wide defaults
├── main.tf                  # Main Terraform module
├── terraform.tf            # Provider configuration and variables
├── terraform.tfvars.example # Example variables file
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

## Configuration Files

### networks.nac.yaml

Contains the main network configuration with the correct YAML structure:
- Uses `meraki.domains.organizations` hierarchy
- Includes complete `product_types` array
- Uses proper field names (`ssid_number`, `vlan_id`)
- Matches validated test fixture format

### defaults.nac.yaml

Defines organization-wide defaults that apply to all networks:
- Wireless SSID defaults (enabled, IP assignment mode)
- Switch settings (power management, uplink sampling)
- Appliance firewall rules

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
- For Terraform provider issues: [Cisco DevNet](https://github.com/cisco-en-programmability/terraform-provider-meraki)
- For professional services: Contact Cisco Professional Services
