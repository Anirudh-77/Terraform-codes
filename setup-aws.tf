#--Create VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc-cidr-block

  azs             = [var.avail-zone]
  public_subnets  = [var.subnet-cidr-block]
  public_subnet_tags = {
    Name = "${var.env-prefix}-subnet"
  }
  tags = {
    Name = "${var.env-prefix}-vpc"
  }
}



module "myapp-server" {
  source = "./modules/webserver"
   vpc-id =  module.vpc.vpc_id
   avail-zone = var.avail-zone
   env-prefix = var.env-prefix
   public-key =  var.public-key
   instance-type = var.instance-type
   subnet-id = module.vpc.public_subnets[0]
}
