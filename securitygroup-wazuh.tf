#*****************************wazuh server sg*******************************

resource "aws_security_group" "wazuh_server_sg" {
  name        = "bb_wazuh_server_sg"
  description = "Allow  on wazuh server"
  vpc_id      = var.vpc_id

  ingress {
    description = "Wazuh agent TCP"
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "22 ansible"
    from_port   = 22
    to_port     = 22
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
    Name = "wazuh-dashboard-sg"
  }
}

#*****************************wazuh indexer sg*******************************

resource "aws_security_group" "wazuh_indexer_sg" {

  name        = "bb_wazuh_indexer_sg"
  description = "Allow  on wazuh indexer"
  vpc_id      = var.vpc_id


  ingress {
    description = "22 ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Optional: Wazuh indexer RESTful API
  ingress {
    description = "Wazuh indexer RESTful API"
    from_port   = 9200
    to_port     = 9200
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
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wazuh-index-sg"
  }
}

#*****************************wazuh dashboard sg*******************************

resource "aws_security_group" "wazuh_dashboard_sg" {

  name        = "bb_wazuh_dashboard_sg"
  description = "Allow  on wazuh dashboar"
  vpc_id      = var.vpc_id

  # Optional: Wazuh indexer RESTful API

  ingress {
    description = "22 ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh dashboard"
    from_port   = 443
    to_port     = 443
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
    Name = "wazuh-dashboard"
  }
}


