#--Declare provider
provider "aws" {
    region= "us-east-1"
    profile="help"
}

#--Declare variables to keep this to local user as .tfvars file is ignored
variable "vpc-cidr-block" {}
variable "subnet-cidr-block" {}
variable "avail-zone" {}
variable "env-prefix" {}
variable instance-type {}
variable public-key {}
variable private-key {}

#--Create VPC
resource "aws_vpc" "test-terra-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    "Name" = "${var.env-prefix}-vpc"
  }
}

#--Create SUBNET
resource "aws_subnet" "test-terra-subnet" {
  vpc_id = aws_vpc.test-terra-vpc.id
  cidr_block = var.subnet-cidr-block
  availability_zone  = var.avail-zone
  tags = {
    "Name" = "${var.env-prefix}-subnet"
  }
}

#--Create SECURITY GROUP
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

#--Create INTERNET GATEWAY
resource "aws_internet_gateway" "test-terra-igw" {
  vpc_id = aws_vpc.test-terra-vpc.id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

#--Create ROUTE TABLE
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

#--Create RT ASSOCIATION
resource "aws_route_table_association" "test-terra-rt-assoc" {
  subnet_id = aws_subnet.test-terra-subnet.id
  route_table_id = aws_route_table.test-terra-rt.id
}

#--get always updated ami id of a linux 
data "aws_ami" "latest-linux-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#--Output instance id

# output "test-instance" {
#   value = data.aws_ami.latest-linux-ami.id
# }

#--Create EC2 INSTANCE
resource "aws_instance" "name" {
  ami = data.aws_ami.latest-linux-ami.id
  security_groups = [aws_security_group.test-terra-sg.id]
  instance_type = var.instance-type
  subnet_id = aws_subnet.test-terra-subnet.id
  availability_zone = var.avail-zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  
#--conection to host remotly and runnung some script  
#-- provisioner is not recomended
  # connection {
  #   type = "ssh"
  #   host = self.public_ip
  #   user = "ec2-user"
  #   private_key = "${file(var.private-key)}"
  # }

#--remotly execute command in instance
  
  # provisioner "remote-exec" {
  #   inline = [
  #     "export ENV=dev",
  #     "mkdir new-folder"
  #   ]
  # }
#-- copy file from local to remote instance
  # provisioner "file" {
  #   source = "entry-script.sh"
  #   destination = "/home/ec2-user/entry-script-on-ec2.sh"
  # }

#-ecxecute commands on local machine
  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} > pub-ip.txt"
  # }


#--Describe user data/script to be ran at start of instance

  # user_data = <<EOF
  #                 #!/bin/bash
  #                 sudo yum update -y && sudo yum install -y docker
  #                 sudo systemctl start docker
  #                 sudo usermod -aG docker ec2-user
  #                 docker run -itd -p 8080:80 nginx
  #             EOF

#-- user data/script as a input file 

#user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env-prefix}-instance"
  }
}

output "public-ip" {
  value = aws_instance.name.public_ip
}

#--Create KEY-PAIR

resource "aws_key_pair" "ssh-key" {
  key_name = "global-1"
  public_key = "${file(var.public-key)}"
}

