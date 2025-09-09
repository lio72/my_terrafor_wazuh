resource "aws_security_group" "wazuh" {
  name        = "wazuh"
  description = "Allow Wazuh ports"
  vpc_id      = "vpc-0c1516a1414edff21"

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

resource "aws_instance" "bb_indexer_cluser" {
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
  availability_zone = "us-east-1a"
  size              = 50
  type              = "gp3"

  tags = {
    Name = "aws_ebs_volume_wi"
  }
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
  availability_zone = "us-east-1a"
  size              = 40
  type              = "gp3"

  tags = {
    Name = "aws_ebs_volume_ws"
  }
}

resource "aws_instance" "bb_dashboard" {
  ami           = "ami-0b0012dad04fbe3d7"
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = "subnet-015774f3e2f32a2e8"
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

