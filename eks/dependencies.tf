data "aws_availability_zones" "current_region" {
  state = "available"
}

resource "tls_private_key" "k8s_nodes_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_nodes_generated_key" {
  key_name   = "eks_nodes_key_pair"
  public_key = tls_private_key.k8s_nodes_private_key.public_key_openssh
}
