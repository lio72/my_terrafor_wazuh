resource "aws_security_group" "wazuh" {
  name        = "wazuh"
  description = "Allow Wazuh ports"
  vpc_id      = "vpc-043af9d5ae9af462f"

  ingress {
    description = "Wazuh agent TCP"
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh 80 ansible"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh 22 ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh 443 ansible"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh agent UDP"
    from_port   = 1514
    to_port     = 1514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh API"
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh registration"
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional: Wazuh cluster daemon
  ingress {
    description = "Wazuh registration"
    from_port   = 1516
    to_port     = 1516
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Optional: Wazuh indexer RESTful API
  ingress {
    description = "Wazuh indexer RESTful API"
    from_port   = 9200
    to_port     = 9299
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Wazuh indexer cluster communication
  ingress {
    description = "Wazuh indexer cluster communication"
    from_port   = 9300
    to_port     = 9400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  

  # Optional: Syslog
  ingress {
    description = "Syslog TCP"
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Syslog UDP"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wazuh"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your local public key
}

resource "aws_instance" "bb_indexer_cluster" {
  for_each     = local.instance_wazuh_indexer 
  ami           = "ami-0b0012dad04fbe3d7" 
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.wazuh.id]
  root_block_device  {
    volume_size = 40
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true     
  }

  user_data = file("mount-ebs.sh")
  # Attach the EBS volume after creation
  depends_on = [aws_ebs_volume.aws_ebs_volume_wi] 

  tags = {
    Name = each.value.name
  }
}

resource "aws_ebs_volume" "aws_ebs_volume_wi" {
  for_each     = local.instance_wazuh_indexer 
  availability_zone = each.value.az
  size              = 40
  type              = "gp3"

  tags = {
    Name = "aws_ebs_wi_${each.value.az}"
  }
}

resource "aws_volume_attachment" "ebs_wi_att" {
  count       = 3
  device_name = "/dev/xvdf"

  volume_id   = local.volume_id_wi_set[count.index]
  instance_id = local.instance_id_wi_set[count.index]
  force_detach = true
  depends_on = [aws_ebs_volume.aws_ebs_volume_wi, aws_instance.bb_indexer_cluster]
}

resource "aws_instance" "bb_server_cluster" {
  for_each     = local.instance_wazuh_server 
  ami           = "ami-0b0012dad04fbe3d7"
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.wazuh.id]
  root_block_device  {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true     
  }
  user_data = file("mount-ebs.sh")

  tags = {
    Name = each.value.name
  }
  # Attach the EBS volume after creation
  depends_on = [aws_ebs_volume.aws_ebs_volume_ws]  
}

resource "aws_ebs_volume" "aws_ebs_volume_ws" {
  for_each     = local.instance_wazuh_server 
  availability_zone = each.value.az
  size              = 40
  type              = "gp3"

  tags = {
    Name = "aws_ebs_wi_${each.value.az}"
  }
}

resource "aws_volume_attachment" "ebs_ws_att" {
  count       = 2
  device_name = "/dev/xvdf"
  volume_id   = local.volume_id_ws_set[count.index]
  instance_id = local.instance_id_ws_set[count.index]
  force_detach = true
  depends_on = [aws_ebs_volume.aws_ebs_volume_ws, aws_instance.bb_server_cluster]
}

resource "aws_instance" "bb_dashboard" {
  ami           = "ami-0b0012dad04fbe3d7"
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = "subnet-03ffb42dfb0448a9e"
  vpc_security_group_ids = [aws_security_group.wazuh.id]
  root_block_device  {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true     
  }

  tags = {
    Name = "dashboard"
  }
}





# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"

#   for_each = toset(["server1", "server2", "server3", "server4", "server5", "server6", "agent1", "agent2"])

#   name = "instance-${each.key}"
#   ami = "ami-0360c520857e3138f"
#   key_name      = aws_key_pair.deployer.key_name

#   instance_type = "t4g.medium"
#   monitoring    = true
#   subnet_id     = "subnet-0196faaf1261ff15b"
#   create_security_group = false
#   vpc_security_group_ids = [aws_security_group.wazuh.id]
#   root_block_device = {
#     volume_size = 30
#     volume_type = "gp3"
#     delete_on_termination = true
#     encrypted = true  
    
#   }

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

