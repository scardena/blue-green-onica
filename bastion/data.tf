data "aws_vpc" "vpc" {
   tags = {
     Name = "vpc-name"
   }
}

data "aws_security_group" "internal_traffic" {
   tags = {
     Name = "onica-internal"
   }
}

data "aws_subnet" "private_sn_1" {
   tags = {
     Name = "onica-vpc-private-us-east-1a"
   }
}

data "aws_subnet" "private_sn_2" {
   tags = {
     Name = "onica-vpc-private-us-east-1b"
   }
}

data "aws_subnet" "private_sn_3" {
   tags = {
     Name = "onica-vpc-private-us-east-1c"
   }
}

data "aws_subnet" "public_sn_1" {
   tags = {
     Name = "onica-vpc-public-us-east-1a"
   }
}

data "aws_subnet" "public_sn_2" {
   tags = {
     Name = "onica-vpc-public-us-east-1b"
   }
}

data "aws_subnet" "public_sn_3" {
   tags = {
     Name = "onica-vpc-public-us-east-1c"
   }
}
