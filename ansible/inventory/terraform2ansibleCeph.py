#!/usr/bin/env python

import sys
import os
import json
import argparse
import collections
import re

__description__ = """Ansible Dynamic Inventory for Terraform."""
__epilog__ = """
The environment variable `TERRAFORM_TFSTATE` must point to the
location of the Terraform state file to use.
"""
parser = argparse.ArgumentParser(description=__description__,
                                 epilog=__epilog__)
parser.add_argument("--list", action="store_true", default=False)
parser.add_argument("--host", action="store", dest='host')
args = parser.parse_args()

state_file = "terraform/04_ceph.tfstate"

try:
    with open(state_file) as f:
        state = json.loads(f.read())
except IOError as e:
    print("No state file found at '%s'" % state_file)
    exit(1)

inventory = collections.defaultdict(dict)
inventory["_meta"]["hostvars"] = {}

for m in state["modules"]:
    module = m["path"].pop()
    for k, attrs in m["resources"].items():
        m = re.search("aws_instance\.([^.]*)\.?(.*)", k)
        if m is not None:
            tf_group = m.group(1)
            attributes = attrs["primary"]["attributes"]
            addressable_host = attributes["private_ip"]
            index = int(m.group(2))
            hostname = "%s%d" % (tf_group, index + 1)
            attributes["ansible_hostname"] = hostname
            attributes["hostname"] = hostname
            attributes["ansible_ssh_host"] = attributes["private_ip"]
            attributes["ip"] = attributes["private_ip"]
#            attributes["ansible_default_ipv4"] = attributes["private_ip"]
            if "hosts" not in inventory[tf_group]:
                inventory[tf_group]["hosts"] = []

#            for role in attributes["tags.Roles"].split(","):
#                if "hosts" not in inventory[role]:
#                    inventory[role]["hosts"] = []
#                inventory[role]["hosts"].append(hostname)

            inventory[tf_group]["hosts"].append(hostname)
            inventory["_meta"]["hostvars"][hostname] = attributes

# inventory["k8s-cluster"]["children"]=["kube-node","kube-master"]

if args.list:
    print(json.dumps(inventory, indent=3))
    exit(0)
elif args.host:
    print(json.dumps(inventory['_meta']['hostvars'][args.host], indent=3))
    exit(0)
else:
    parser.print_help()
    exit(1)
