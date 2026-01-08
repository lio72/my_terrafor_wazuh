resource "aws_lb" "nlb_wazuh" {
  name               = "wazuh-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.wazuh_nlb_sg.id]
  subnets            = ["subnet-0355b21e78ce62623", "subnet-0519b7228361a4ff1", "subnet-0c0651360b5d8528c"]

  enable_deletion_protection = false
  depends_on = [aws_security_group.wazuh_nlb_sg]
}

# Target Groups for ports 1514 and 1515
resource "aws_lb_target_group" "tg_1514" {
  name     = "tg-1514"
  port     = 1514
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "tg_1515" {
  name     = "tg-1515"
  port     = 1515
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "tg_55000" {
  name     = "tg-55000"
  port     = 55000
  protocol = "TCP"
  vpc_id   = var.vpc_id
}


# TLS Listeners with ACM Certificate
resource "aws_lb_listener" "listener_1514" {
  load_balancer_arn = aws_lb.nlb_wazuh.arn
  port              = 1514
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1514.arn
  }
}

resource "aws_lb_listener" "listener_1515" {
  load_balancer_arn = aws_lb.nlb_wazuh.arn
  port              = 1515
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1515.arn
  }
}

resource "aws_lb_listener" "listener_55000" {
  load_balancer_arn = aws_lb.nlb_wazuh.arn
  port              = 55000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_55000.arn
  }
}

# attachement

resource "aws_lb_target_group_attachment" "atach_1514" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.bb_server_cluster :
    k => v
  }
  target_group_arn = aws_lb_target_group.tg_1514.arn
  target_id        = each.value.id
  port             = 1514
  depends_on = [aws_instance.bb_server_cluster]
}

resource "aws_lb_target_group_attachment" "atach_1515" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.bb_server_cluster :
    k => v
  }
  target_group_arn = aws_lb_target_group.tg_1515.arn
  target_id        = each.value.id
  port             = 1515
  depends_on = [aws_instance.bb_server_cluster]
}


resource "aws_lb_target_group_attachment" "atach_55000" {
  # covert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in aws_instance.bb_server_cluster :
    k => v
  }
  target_group_arn = aws_lb_target_group.tg_55000.arn
  target_id        = each.value.id
  port             = 55000
  depends_on = [aws_instance.bb_server_cluster]
}