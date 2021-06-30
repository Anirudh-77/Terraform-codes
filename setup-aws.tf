provider "aws" {
    region= "us-east-1"
    profile="help"
}

variable "vpc-cidr-block" {}
variable "subnet-cidr-block" {}
variable "avail-zone" {}
variable "env-prefix" {}
variable instance-type {}
variable public-key {}


resource "aws_vpc" "test-terra-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    "Name" = "${var.env-prefix}-vpc"
  }
}


resource "aws_subnet" "test-terra-subnet" {
  vpc_id = aws_vpc.test-terra-vpc.id
  cidr_block = var.subnet-cidr-block
  availability_zone  = var.avail-zone
  tags = {
    "Name" = "${var.env-prefix}-subnet"
  }
}

resource "aws_security_group" "test-terra-sg" {
  name        = "All traffic"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.test-terra-vpc.id
  

  ingress {
    description      = "All"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env-prefix}-sg"
  }
}

resource "aws_internet_gateway" "test-terra-igw" {
  vpc_id = aws_vpc.test-terra-vpc.id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}


resource "aws_route_table" "test-terra-rt" {
  vpc_id = aws_vpc.test-terra-vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-terra-igw.id
  }

  tags = {
    "Name" = "${var.env-prefix}-rt"
  }
}

resource "aws_route_table_association" "test-terra-rt-assoc" {
  subnet_id = aws_subnet.test-terra-subnet.id
  route_table_id = aws_route_table.test-terra-rt.id
}


data "aws_ami" "latest-linux-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# output "test-instance" {
#   value = data.aws_ami.latest-linux-ami.id
# }

resource "aws_instance" "name" {
  ami = data.aws_ami.latest-linux-ami.id
  security_groups = [aws_security_group.test-terra-sg.id]
  instance_type = var.instance-type
  subnet_id = aws_subnet.test-terra-subnet.id
  availability_zone = var.avail-zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  tags = {
    Name = "${var.env-prefix}-instance"
  }
}

# output "public-ip" {
#   value = aws_instance.name.public_ip
# }

resource "aws_key_pair" "ssh-key" {
  key_name = "global-1"
  public_key = "${file(var.public-key)}"
}