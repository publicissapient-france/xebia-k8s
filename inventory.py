#!/usr/bin/env python
#  Ansible: initialize needed objects

import sys
from ansible.inventory import Inventory
from ansible.parsing.dataloader import DataLoader
from ansible.vars import VariableManager

variable_manager = VariableManager()
loader = DataLoader()

#  Ansible: Load inventory
inventory = Inventory(
    loader=loader,
    variable_manager=variable_manager,
    host_list='./ansible/inventory',  # Substitute your filename here
)

show_header = True
search_host = None
search_attr = None
if len(sys.argv) > 1:
    search_host = sys.argv[1]

if len(sys.argv) > 2:
    search_attr = sys.argv[2]
    show_header = False

data = dict()
max = 0

for group in inventory.get_groups():
    for host in inventory.get_group(group).hosts:
        if search_host is not None and host.name != search_host:
            continue

        if search_host == host.name and search_attr is not None:
            print host.vars[search_attr]
            exit(0)

        if not host.name in data:
            max = max if max > len(host.name) else len(host.name)
            data[host.name] = host

if show_header:
    print "%s   %s  %s" % ('host'.ljust(max), 'ansible_ssh_host'.ljust(15), 'private_ip'.ljust(15))
    print '-' * 80
for host in data:
    print "%s   %s  %s" % (
        data[host].name.ljust(max), data[host].vars['ansible_ssh_host'].ljust(15),
        data[host].vars['private_ip'].ljust(15))
