Host 10.*
    ProxyCommand ssh -F ${config_path}/properties/ssh/ssh-bastion.conf -W %h:%p bastion
    StrictHostKeyChecking no
    IdentityFile properties/ssh/rsakey
    User ubuntu

Host bastion
    Hostname ${public_ip_address_bastion}
    StrictHostKeyChecking no
    User ubuntu
    IdentityFile properties/ssh/rsakey

Host *
    ControlMaster auto
    ControlPath ~/.ssh/ansible-%r@%h:%p
    ControlPersist 5m
