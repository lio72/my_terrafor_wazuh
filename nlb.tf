resource "aws_lb" "nlb_wazuh" {
  name               = "wazuh-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.wazuh-nlb_sg.id]
  subnets            = ["subnet-04f7bc466430fca7f", "subnet-0a8611f6118f67885", "subnet-05546f7b8f197e3ed"]

  enable_deletion_protection = false
}

# Target Groups for ports 1514 and 1515
resource "aws_lb_target_group" "tg_1514" {
  name     = "tg-1514"
  port     = 1514
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "tg_1515" {
  name     = "tg-1515"
  port     = 1515
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "tg_55000" {
  name     = "tg-55000"
  port     = 55000
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
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