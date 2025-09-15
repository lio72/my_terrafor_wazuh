resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your local public key
}

################### wazuh indexer ############################

resource "aws_instance" "bb_indexer_cluster" {
  for_each     = local.instance_wazuh_indexer 
  ami           = "ami-0b0012dad04fbe3d7" 
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.wazuh_indexer_sg.id]
  root_block_device  {
    volume_size = 40
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true     
  }

  user_data = file("mount-ebs-index.sh")
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

################### wazuh server ############################

resource "aws_instance" "bb_server_cluster" {
  for_each     = local.instance_wazuh_server 
  ami           = "ami-0b0012dad04fbe3d7"
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.wazuh_server_sg.id]
  root_block_device  {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
    encrypted = true     
  }
  user_data = file("mount-ebs-server.sh")

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
    Name = "bb-ebs_wi_${each.value.az}"
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

#create tg for nlb


resource "aws_lb_target_group_attachment" "atach_1514" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.bb_server_cluster :
    k => v
  }
  target_group_arn = aws_lb_target_group.nlb_wazuh.arn
  target_id        = each.value.id
  port             = 1514
}

resource "aws_lb_target_group_attachment" "atach_1515" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.bb_server_cluster :
    k => v
  }
  target_group_arn = aws_lb_target_group.nlb_wazuh.arn
  target_id        = each.value.id
  port             = 1515
}
#################wazuh dashboard #####################################
resource "aws_instance" "bb_dashboard" {
  ami           = "ami-0b0012dad04fbe3d7"
  key_name      = aws_key_pair.deployer.key_name
  instance_type = "t3.medium"
  monitoring    = true
  subnet_id     = "subnet-03f0870b60d122b9d"
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.wazuh_dashboard_sg.id]
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