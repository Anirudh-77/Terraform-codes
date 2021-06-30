provider "aws" {
    region= "us-east-1"
    profile="help"
}

resource "aws_vpc" "test-terra-vpc" {
  cidr_block = var.vpc-subnet-data[0].cidr-block
  tags = {
    "Name" = var.vpc-subnet-data[0].name
  }
}

variable "vpc-subnet-data" {
  description = "subnet cidr block and names for vpc and subnet"
  type = list(object({
    cidr-block = string,
    name = string
  }))

}

resource "aws_subnet" "test-terra-subnet" {
  vpc_id = aws_vpc.test-terra-vpc.id
  cidr_block = var.vpc-subnet-data[1].cidr-block
  availability_zone  = "us-east-1a"
  tags = {
    "Name" = var.vpc-subnet-data[1].name
  }
}

# data "aws_vpc" "test-vpc-data" {
#   default = true

# }

# resource "aws_subnet" "data-subnet" {
    
#   vpc_id = data.aws_vpc.test-vpc-data.id
#   cidr_block = 
#   availability_zone  = "us-east-1a"
# }

output "vpc-id" {
  value = aws_subnet.test-terra-subnet.id
}

output "subnet-id" {
  value = aws_vpc.test-terra-vpc.id
}