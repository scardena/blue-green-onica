provider "aws" {
  region = "us-east-1"
}


module "bastion" {
  source = "umotif-public/bastion/aws"
  version = "~> 1.0"

  name_prefix = "Onica-bastion"

  vpc_id         = data.aws_vpc.vpc.id
  public_subnets        = [data.aws_subnet.public_sn_1.id,data.aws_subnet.public_sn_2.id,data.aws_subnet.public_sn_3.id] 
  ssh_key_name   = "onica"
  #Lock this to office/vpn only

  ingress_cidr_blocks = []

  tags = {
    Project = "Test"
  }
}
