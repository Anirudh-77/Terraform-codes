#--Create VPC
resource "aws_vpc" "test-terra-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    "Name" = "${var.env-prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnets"
  vpc-id = aws_vpc.test-terra-vpc.id
  avail-zone = var.avail-zone
  env-prefix = var.env-prefix
  subnet-cidr-block = var.subnet-cidr-block
}

module "myapp-server" {
  source = "./modules/webserver"
   vpc-id =  aws_vpc.test-terra-vpc.id
   avail-zone = var.avail-zone
   env-prefix = var.env-prefix
   public-key =  var.public-key
   instance-type = var.instance-type
   subnet-id = module.myapp-subnet.subnet.id 

}
