
before deploy wazuh infra, create ssh key


#### deploy ssh key

ssh-keygen -t rsa -b 4096 -C "yamkamlionel@gmail.com" 

#### get private key an save it in

~/.ssh/ke 

#### set vpc id in ec2.tf

1*** deploy vpc
2*** deploy ec2 nb: edit ec2 wazuh variables adding new vpc_id an new subnets_id

3*** deploy NLb



