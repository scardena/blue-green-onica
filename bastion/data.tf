data "aws_vpc" "vpc" {
   tags = {
     Name = "vpc-name"
   }
}

data "aws_security_group" "internal_traffic" {
   tags = {
     Name = "lemon-internal"
   }
}

data "aws_subnet" "private_sn_1" {
   tags = {
     Name = "limontech-vpc-private-us-east-1a"
   }
}

data "aws_subnet" "private_sn_2" {
   tags = {
     Name = "limontech-vpc-private-us-east-1b"
   }
}

data "aws_subnet" "private_sn_3" {
   tags = {
     Name = "limontech-vpc-private-us-east-1c"
   }
}

data "aws_subnet" "public_sn_1" {
   tags = {
     Name = "limontech-vpc-public-us-east-1a"
   }
}

data "aws_subnet" "public_sn_2" {
   tags = {
     Name = "limontech-vpc-public-us-east-1b"
   }
}

data "aws_subnet" "public_sn_3" {
   tags = {
     Name = "limontech-vpc-public-us-east-1c"
   }
}
