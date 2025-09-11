# # vpc subnet and az for wazuh

# variable "vpc_id" {
#   type = string
#   default =  "vpc-08e0e023f53f5fba5"
# }

# variable "subnet_ids" {
#   type    = list(string)
#   default = [
#     "subnet-0bd57b7fdbeffa0e4",
#     "subnet-024d2925bd8641106",
#     "subnet-07c093091f049dd81"
#   ]
# }

# variable "subnet_az" {
#   type    = list(string)
#   default = [
#     "us-east-1b",
#     "us-east-1c",
#     "us-east-1d"
#   ]
# }

# # variable for wazuh indexer cluster

# variable "indexer_instance_names" {
#   type    = list(string)
#   default = [
#     "bb-wazuh_indexer-1",
#     "bb-wazuh_indexer-2",
#     "bb-wazuh_indexer-3"
#   ]
# }
# locals {
#   instance_wazuh_indexer = {
#     for idx in range(length(var.subnet_ids)) :
#     var.indexer_instance_names[idx] => {
#       subnet_id = var.subnet_ids[idx]
#       name      = var.indexer_instance_names[idx]
#       az        = var.subnet_az[idx]
#     }
#   }
# }


# # varible for wazuh server cluster

# variable "server_instance_names" {
#   type    = list(string)
#   default = [
#     "bb-wazuh_manager",
#     "bb-wazuh_worker"
#   ]
# }
# locals {
#   instance_wazuh_server = {
#     for idx in range(length(var.subnet_ids)-1) :
#     var.server_instance_names[idx] => {
#       subnet_id = var.subnet_ids[idx]
#       name      = var.server_instance_names[idx]
#       az        = var.subnet_az[idx]
#     }
#   }
# }

# # variable for volume wazuh server attachment
# locals {
#   volume_id_ws_set = [for v in aws_ebs_volume.aws_ebs_volume_ws : v.id]
# }

# locals {
#   instance_id_ws_set = [for v in aws_instance.bb_server_cluster : v.id]
# }
# # variable for volume wazuh indexer  attachment

# locals {
#   volume_id_wi_set = [for v in aws_ebs_volume.aws_ebs_volume_wi : v.id]
# }

# locals {
#   instance_id_wi_set = [for v in aws_instance.bb_indexer_cluster : v.id]
# }