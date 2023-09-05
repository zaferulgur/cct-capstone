## create all network resources as new ###

/* VPC */
resource "aws_vpc" "eks_cluster" {
  count = contains(local.var.flags, "create_network") ? 1 : 0

  cidr_block           = format("%s.0.0/16", local.var.network.vpc.prefix_subnet)
  enable_dns_hostnames = true

  tags = {
    Name        = "${terraform.workspace}-vpc"
    Description = "VPC for ${terraform.workspace}."
  }
}

/* Private Subnet */
resource "aws_subnet" "eks_private" {
  count             = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  vpc_id            = aws_vpc.eks_cluster[0].id
  cidr_block        = cidrsubnet(format("%s.100.0/20", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), (count.index + 1))
  availability_zone = data.aws_availability_zones.current_region.names[count.index]

  tags = {
      Name                              = "${terraform.workspace}-Private-${data.aws_availability_zones.current_region.names[count.index]}-subnet"
      Description                       = "Private Subnet for ${terraform.workspace}."
      "kubernetes.io/role/internal-elb" = 1
  }
}
/* Public Subnet */
resource "aws_subnet" "eks_public" {
  count             = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  vpc_id            = aws_vpc.eks_cluster[0].id
  cidr_block        = cidrsubnet(format("%s.0.0/21", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), count.index)
  availability_zone = data.aws_availability_zones.current_region.names[count.index]

  tags = {
      Name                     = "${terraform.workspace}-Public-${data.aws_availability_zones.current_region.names[count.index]}-subnet"
      Description              = "Public Subnet for ${terraform.workspace}."
      "kubernetes.io/role/elb" = 1
  }
}


/* Gateways Nat and Internet */
resource "aws_eip" "eks_eip" {
  count = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  vpc   = true

  tags = {
    Name        = "${terraform.workspace}-${data.aws_availability_zones.current_region.names[count.index]}-eip"
    Description = "Elastic IP for NAT Gateway of ${terraform.workspace}"
  }
}
resource "aws_nat_gateway" "eks_natgw" {
  count         = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  allocation_id = element(aws_eip.eks_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.eks_public.*.id, count.index)

  depends_on    = [
    aws_subnet.eks_public
  ]

  tags = {
    Name        = "${terraform.workspace}-${data.aws_availability_zones.current_region.names[count.index]}-natgw"
    Description = "NAT Gateway for ${data.aws_availability_zones.current_region.names[count.index]} of ${terraform.workspace}"
  }
}
resource "aws_internet_gateway" "eks_igw" {
  count   = contains(local.var.flags, "create_network") ? 1 : 0

  vpc_id  = aws_vpc.eks_cluster[0].id

  tags = {
    Name        = "${terraform.workspace}-igw"
    Description = "Internet Gateway for Public Subnets of ${terraform.workspace}"
  }
}


/* Route Tables */
resource "aws_route_table" "eks_private_rt" {
  count  = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  vpc_id  = aws_vpc.eks_cluster[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.eks_natgw.*.id, count.index)
  }

  # dynamic "route" {
  #   for_each = local.var.network.routes.transit_gateway.cidr_blocks

  #   content {
  #     cidr_block = route.value
  #     transit_gateway_id = local.var.network.routes.transit_gateway.id
  #   }
  # }

  depends_on = [
    aws_nat_gateway.eks_natgw
  ]

  tags = {
    Name        = "${terraform.workspace}-Private-${data.aws_availability_zones.current_region.names[count.index]}-rt"
    Description = "Route table Target to Nat Gateway for ${terraform.workspace}"
  }
}
resource "aws_route_table" "eks_public_rt" {
  count  = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  vpc_id  = aws_vpc.eks_cluster[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw[0].id
  }

  depends_on = [
    aws_internet_gateway.eks_igw
  ]

  tags = {
    Name        = "${terraform.workspace}-Public-${data.aws_availability_zones.current_region.names[count.index]}-routetable"
    Description = "Route table Target to Internet Gateway for ${terraform.workspace}"
  }
}


/* Route Table Association to Public and Private Subnets */
resource "aws_route_table_association" "eks_private_rta" {
  count          = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  subnet_id      = element(aws_subnet.eks_private.*.id, count.index)
  route_table_id = element(aws_route_table.eks_private_rt.*.id, count.index)

  depends_on = [
    aws_subnet.eks_private ,
    aws_route_table.eks_private_rt,
  ]
}
resource "aws_route_table_association" "eks_public_rta" {
  count          = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  subnet_id      = element(aws_subnet.eks_public.*.id, count.index)
  route_table_id = element(aws_route_table.eks_public_rt.*.id, count.index)

  depends_on = [
    aws_subnet.eks_public,
    aws_route_table.eks_public_rt,
  ]
}
