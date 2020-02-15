provider "aws" {
  region = "us-east-1"
}


module "elastic_beanstalk_application" {
    source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=tags/0.3.0"
    #namespace   = "limoneno"
    #stage       = ""
    name        = "backend"
    description = "Test elastic_beanstalk_application"
  }

module "elastic_beanstalk_environment" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=master"
  #namespace                          = var.namespace
  #stage                              = var.stage
  name                               = "backend-blue"
  description                        = "backend-blue"
  region                             = "us-east-1"
  #availability_zone_selector         = "Any 2"
  #dns_zone_id                        = var.dns_zone_id
  elastic_beanstalk_application_name = module.elastic_beanstalk_application.elastic_beanstalk_application_name
  force_destroy = true

  instance_type           = "t3.micro"
  keypair                 = "limon"
  autoscale_min           = 1
  autoscale_max           = 2
  updating_min_in_service = 0
  updating_max_batch      = 1

  loadbalancer_type       = "application"
  healthcheck_url 	  = "/"
  vpc_id                  = data.aws_vpc.vpc.id 
  loadbalancer_subnets    = [data.aws_subnet.public_sn_1.id,data.aws_subnet.public_sn_2.id,data.aws_subnet.public_sn_3.id]              
  application_subnets     = [data.aws_subnet.private_sn_1.id,data.aws_subnet.private_sn_2.id,data.aws_subnet.private_sn_3.id]              
  allowed_security_groups = [data.aws_security_group.internal_traffic.id]                    

  // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html
  // https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.14.1 running Docker 18.09.9-ce"
  
}
