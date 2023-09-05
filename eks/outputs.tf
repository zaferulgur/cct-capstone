### Outputs of Network Components ###
output "vpc_id" {
  value       = concat(aws_vpc.eks_cluster.*.id, [""])[0]
  description = "The ID of the VPC"
}
output "vpc" {
  value       = aws_vpc.eks_cluster
  description = "The Object of the VPC"
}
output "private_subnet_ids" {
  value       = aws_subnet.eks_private.*.id
  description = "List of IDs of Private Subnets"
}
output "public_subnet_ids" {
  value       = aws_subnet.eks_public.*.id
  description = "List of IDs of Public Subnets"
}
output "eip_ids" {
  value = aws_eip.eks_eip.*.id
  description = "List of IDs of Elastic IPs"
}
output "nat_gateway_ids" {
  value       = concat(aws_nat_gateway.eks_natgw.*.id)
  description = "List of IDs of NAT Gateways"
}
output "internet_gateway_id" {
  value       = try(aws_internet_gateway.eks_igw[0].id, null)
  description = "The ID of the Internet Gateway"
}
output "private_route_table_ids" {
  value       = aws_route_table.eks_private_rt.*.id
  description = "List of IDs of Private Route Tables"
}
output "public_route_table_ids" {
  value       = aws_route_table.eks_public_rt.*.id
  description = "List of IDs of Public Route Tables"
}

output "eks_nodes_ssh_private_key" {
  value     = tls_private_key.k8s_nodes_private_key.private_key_pem
  sensitive = true
}
