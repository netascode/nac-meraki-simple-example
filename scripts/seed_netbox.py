#!/usr/bin/env python3
"""Create the sample NetBox objects that netbox.tf reads. For a TEST NetBox only.

Idempotent: existing objects are left untouched. Needs NETBOX_URL and NETBOX_TOKEN.
"""
import os
import sys

import requests

URL = os.environ["NETBOX_URL"].rstrip("/") + "/api"
S = requests.Session()
S.headers.update({"Authorization": f"Bearer {os.environ['NETBOX_TOKEN']}", "Accept": "application/json"})

# site, device, third octet pair: data VLAN 100 -> 10.<n>.100.0/24, voice VLAN 200 -> 10.<n>.200.0/24
BRANCHES = [("Rome Branch 01", "mx-rome-01", 10), ("Lisbon Branch 01", "mx-lisbon-01", 20)]
VLANS = {100: "Data", 200: "Voice"}


def ensure(path, lookup, body):
    r = S.get(f"{URL}/{path}/", params=lookup)
    r.raise_for_status()
    found = r.json()
    if found["count"] > 1:
        sys.exit(f"ambiguous {path} {lookup}: {found['count']} matches")
    if found["count"] == 1:
        return found["results"][0]
    r = S.post(f"{URL}/{path}/", json=body)
    r.raise_for_status()
    return r.json()


mf = ensure("dcim/manufacturers", {"slug": "cisco-meraki"}, {"name": "Cisco Meraki", "slug": "cisco-meraki"})
dt = ensure("dcim/device-types", {"slug": "mx68"}, {"manufacturer": mf["id"], "model": "MX68", "slug": "mx68"})
role = ensure("dcim/device-roles", {"slug": "security-appliance"},
              {"name": "Security Appliance", "slug": "security-appliance", "color": "2196f3"})

for site_name, dev_name, n in BRANCHES:
    slug = site_name.lower().replace(" ", "-")
    site = ensure("dcim/sites", {"slug": slug}, {"name": site_name, "slug": slug, "status": "active"})
    dev = ensure("dcim/devices", {"name": dev_name},
                 {"name": dev_name, "device_type": dt["id"], "role": role["id"], "site": site["id"], "status": "active"})
    for vid, label in VLANS.items():
        vlan = ensure("ipam/vlans", {"vid": vid, "site_id": site["id"]},
                      {"vid": vid, "name": f"{label}-{slug}", "site": site["id"]})
        prefix = f"10.{n}.{vid}.0/24"
        ensure("ipam/prefixes", {"prefix": prefix}, {"prefix": prefix, "vlan": vlan["id"], "status": "active",
                                                      "scope_type": "dcim.site", "scope_id": site["id"]})
        iface = ensure("dcim/interfaces", {"device_id": dev["id"], "name": f"vlan{vid}"},
                       {"device": dev["id"], "name": f"vlan{vid}", "type": "virtual"})
        ensure("ipam/ip-addresses", {"address": f"10.{n}.{vid}.1/24"},
               {"address": f"10.{n}.{vid}.1/24", "status": "active",
                "assigned_object_type": "dcim.interface", "assigned_object_id": iface["id"]})
        print(f"{site_name}: VLAN {vid} {prefix} gw 10.{n}.{vid}.1")
