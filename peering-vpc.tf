# Variables d'exemple
variable "vpc_id_1" { default = "vpc-05481faafad3e09f7" }
variable "vpc_id_2" { default = "vpc-0ac3ef7da834f76c6" }
variable "peer_region" { default = "us-east-1" }

# Création du peering
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = var.vpc_id_1
  peer_vpc_id   = var.vpc_id_2
  auto_accept   = false             # true si même compte

  # Si cross-region
  peer_region   = var.peer_region

  tags = {
    Name = "peering-vpc1-vpc2"
  }
}

# Accepter la connexion de peering (à utiliser si auto_accept = false)
resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}

# Mise à jour des routes dans chaque VPC
resource "aws_route" "route_to_peer_1" {
  route_table_id         = "rtb-05dc37ecf001e8080" # Remplace par la route table de VPC 1
  destination_cidr_block = "10.0.0.0/16" # CIDR du VPC 2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_to_peer_2" {
  route_table_id         = "rtb-0bf5c956acc4877e8" # Remplace par la route table de VPC 2
  destination_cidr_block = "172.31.0.0/16" # CIDR du VPC 1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}