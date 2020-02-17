provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "onica-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Owner       = "onica"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}

resource "aws_security_group" "internal_traffic" {
  name_prefix = "Onica"
  description = "Allows all traffic from within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }


  tags = {
    Name = "onica-internal"
  }

}

