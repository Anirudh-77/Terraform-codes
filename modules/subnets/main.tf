#--Create SUBNET
resource "aws_subnet" "test-terra-subnet" {
  vpc_id = var.vpc-id
  cidr_block = var.subnet-cidr-block
  availability_zone  = var.avail-zone
  tags = {
    "Name" = "${var.env-prefix}-subnet"
  }
}

#--Create INTERNET GATEWAY
resource "aws_internet_gateway" "test-terra-igw" {
  vpc_id = var.vpc-id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

#--Create ROUTE TABLE
resource "aws_route_table" "test-terra-rt" {
  vpc_id = var.vpc-id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-terra-igw.id
  }

  tags = {
    "Name" = "${var.env-prefix}-rt"
  }
}

#--Create RT ASSOCIATION
resource "aws_route_table_association" "test-terra-rt-assoc" {
  subnet_id = aws_subnet.test-terra-subnet.id
  route_table_id = aws_route_table.test-terra-rt.id
}
