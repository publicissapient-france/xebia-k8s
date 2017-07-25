#!/usr/bin/env python
#  Ansible: initialize needed objects

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

data = dict()
max = 0
for group in inventory.get_groups():
    for host in inventory.get_group(group).hosts:
        if not host.name in data:
            max =  max if max > len(host.name) else len(host.name)
            data[host.name]=host

print "%s   %s  %s" % ( 'host'.ljust(max) , 'private'.ljust(15),'private'.ljust(15) )
print '-' * 80
for host in data:
    print "%s   %s  %s" % ( data[host].name.ljust(max) , data[host].vars['ansible_ssh_host'].ljust(15),data[host].vars['private_ip'].ljust(15))

