#Create a VPC
resource "aws_vpc" "vpc-2" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-2"
  }
}

#Public subnet
resource "aws_subnet" "public-subnet-2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.vpc-2.id
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

#Private subnet
resource "aws_subnet" "private-subnet-2" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.vpc-2.id
  availability_zone       = "ap-south-1b" 
  tags = {
    Name = "private-subnet-2"
  }
}

// Create internet gateway for public subnet
resource "aws_internet_gateway" "igw-2" {
  vpc_id = aws_vpc.vpc-2.id

  tags = {
    Name = "igw-2"
  }
}

// Create route table
resource "aws_route_table" "public-rt-2" {
  vpc_id = aws_vpc.vpc-2.id

  route {
    cidr_block = "0.0.0.0/0"  #accept traffic from anywhere
    gateway_id = aws_internet_gateway.igw-2.id
  }

  tags = {
    Name = "public-rt-2"
  }
}

// Associate subnet with route table
resource "aws_route_table_association" "rt-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt-2.id
}

# Allocate an Elastic IP for NAT Gateway
resource "aws_eip" "nat-eip-2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw-2" {
  allocation_id = aws_eip.nat-eip-2.id  # Elastic IP for NAT
  subnet_id     = aws_subnet.public-subnet-2.id  # NAT gateway is associated with public subnet with ig

  tags = {
    Name = "Test NAT Gateway-2"
  }
}


#create Route Table for Private Subnet (Routes Traffic to NAT)
resource "aws_route_table" "private-rt-2" {
  vpc_id = aws_vpc.vpc-2.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-2.id  
  }

  tags = {
    Name = "private-rt-2"
  }
}

# Associate Private Subnet with the Private Route Table
resource "aws_route_table_association" "private-assoc-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt-2.id
}

