#create vpc
resource "aws_vpc" "eks_vpc" {
    cidr_block = var.eks_vpc_cidr
    tags = {
    Name = "eks_vpc"
  }
}
#public subnet
resource "aws_subnet" "eks_public_subnet-1" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = var.public_sub1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "eks_public_subnet1"
  }
}
#private subnet
resource "aws_subnet" "eks_public_subnet-2" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = var.public_sub2_cidr
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "eks_public_subnet2"
  }
}
#eks_vpc_igw
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}
#route_table 
resource "aws_route_table" "eks_RT" {
 vpc_id =  aws_vpc.eks_vpc.id
 tags = {
    Name = "eks_vpc_RT"
  }

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
 }
}
#associate RT to public subnets
resource "aws_route_table_association" "eks_public_subnet-1_rt1" {
 subnet_id = aws_subnet.eks_public_subnet-1.id
 route_table_id = aws_route_table.eks_RT.id
}
#associate RT to private subnets
resource "aws_route_table_association" "eks_public_subnet-2_rt1" {
 subnet_id = aws_subnet.eks_public_subnet-2.id
 route_table_id = aws_route_table.eks_RT.id
}

module "sg_eks" {
  source = "./sg_eks"
  vpc_id = aws_vpc.eks_vpc.id
}
module "eks" {
  source = "./eks"
  vpc_id = aws_vpc.eks_vpc.id
  sg_ids = module.sg_eks.security_group_public
  subnet_ids = [aws_subnet.eks_public_subnet-1.id,aws_subnet.eks_public_subnet-2.id]
}
