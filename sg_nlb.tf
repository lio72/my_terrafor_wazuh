resource "aws_security_group" "wazuh_nlb_sg" {

  name        = "bb_wazuh_dashboard_sg"
  description = "Allow  on wazuh dashboar"
  vpc_id      = var.vpc_id

  # Optional: Wazuh indexer RESTful API

  ingress {
    description = "Agent connection service"
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Agent enrollment service"
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wazuh-nlb-sg"
  }
}


