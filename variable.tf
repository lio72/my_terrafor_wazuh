# subnet for wazuh

variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-0b953f562ea88d330",
    "subnet-07926413dcfd5bdd3",
    "subnet-067482b924a2e8c3d"
  ]
}

# variable for wazuh indexer

variable "indexer_instance_names" {
  type    = list(string)
  default = [
    "bb-wazuh_indexer-1",
    "bb-wazuh_indexer-2",
    "bb-wazuh_indexer-3"
  ]
}
locals {
  instance_wazuh_indexer = {
    for idx in range(length(var.subnet_ids)) :
    var.indexer_instance_names[idx] => {
      subnet_id = var.subnet_ids[idx]
      name      = var.indexer_instance_names[idx]
    }
  }
}


# varible for wazuh server

variable "server_instance_names" {
  type    = list(string)
  default = [
    "bb-wazuh_manager",
    "bb-wazuh_worker"
  ]
}
locals {
  instance_wazuh_server = {
    for idx in range(length(var.subnet_ids)-1) :
    var.server_instance_names[idx] => {
      subnet_id = var.subnet_ids[idx]
      name      = var.server_instance_names[idx]
    }
  }
}
