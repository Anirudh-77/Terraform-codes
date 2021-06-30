#--Create SECURITY GROUP
resource "aws_security_group" "test-terra-sg" {
  name        = "All traffic"
  description = "Allow all traffic"
  vpc_id      = var.vpc-id
  

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


#--get always updated ami id of a linux 
data "aws_ami" "latest-linux-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


#--Create KEY-PAIR

resource "aws_key_pair" "ssh-key" {
  key_name = "global-1"
  public_key = "${file(var.public-key)}"
}


#--Create EC2 INSTANCE
resource "aws_instance" "name" {
  ami = data.aws_ami.latest-linux-ami.id
  security_groups = [aws_security_group.test-terra-sg.id]
  instance_type = var.instance-type
  subnet_id = var.subnet-id
  availability_zone = var.avail-zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  

#--Describe user data/script to be ran at start of instance

#   user_data = <<EOF
#                   #!/bin/bash
#                   sudo yum update -y && sudo yum install -y docker
#                   sudo systemctl start docker
#                   sudo usermod -aG docker ec2-user
#                   docker run -itd -p 8080:80 nginx
#               EOF

#-- user data/script as a input file 
 user_data = file("./modules/webserver/entry-script.sh")

  tags = {
    Name = "${var.env-prefix}-instance"
  }
}

