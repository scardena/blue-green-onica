provider "aws" {
  region = "us-east-1"
}

#required for the webhook
#provider "github" {
#  token        = var.github_token
#  individual = "true"
#}

resource "aws_s3_bucket" "codebuild_bucket" {
  bucket        = "test-bucket-codebuild-simon"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_iam_role" "codebuild_role" {
  name               = "code-build-simon-test-role"
  assume_role_policy = file("codebuild_assumerole_policy.txt")
}


resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = file("codebuild_policy.txt")
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "test-codebuild"
  description   = "test_codebuild_project"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  #Terraform doesn't provide a capability to change the log duration in here, so logs will remain regardless if the stack is destroyed.
  #https://www.terraform.io/docs/providers/aws/r/codebuild_project.html#cloudwatch_logs
  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  tags = {
    Environment = "Test"
  }
}



#maybe autogenerate s3 name so it doesn't conflicts with existing ones
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "test-bucket-onica-simon"
  acl           = "private"
  force_destroy = "true"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "test-role-onica-simon"

  assume_role_policy = file("codepipeline_assumerole_policy.txt")
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = file("codepipeline_policy.txt")
}



#No kms for simplicity

#resource "aws_kms_key" "s3kmskey" {
#  description             = "KMS s3"
#  deletion_window_in_days = 10
#}

#data "aws_kms_alias" "s3kmskey" {
#  name = "alias/myKmsKey"
#}

resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    #encryption_key {
    #  id   = "${aws_kms_key.s3kmskey.arn}"
    #  type = "KMS"
    #}
  }

  #Terraform will likely identify everytime the oauthtoken as change all the time. I don't like the workaround that much, so I am just leaving it as it is.
  #https://github.com/terraform-providers/terraform-provider-aws/issues/2854


  #This part doesn't really require to set up the github provider, but this will only work if you want codepipeline to poll the repo. if webhooks are required, you need to set up webhooks, as below, and also set up the github provider.
  stage {
    name = "Source"
    #https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-GitHub.html#action-reference-GitHub-auth
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        OAuthToken           = var.github_token
        Owner                = "scardena"
        Repo                 = "onica-app"
        Branch               = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.codebuild_project.name}"
      }
    }
  }

  #https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html#reference-action-artifacts
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = "onicaapp"
        EnvironmentName = "onica-app-blue"
      }
    }
  }
}


# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.
#locals {
#  webhook_secret = "super-secret-onica"
#}
#
#resource "aws_codepipeline_webhook" "bar" {
#  name            = "test-webhook-github-bar"
#  authentication  = "GITHUB_HMAC"
#  target_action   = "Source"
#  target_pipeline = aws_codepipeline.codepipeline.name
#
#  authentication_configuration {
#    secret_token = local.webhook_secret
#  }
#
#  filter {
#    json_path    = "$.ref"
#    match_equals = "refs/heads/{Branch}"
#  }
#}



#NOTE!
#Terraform doesn't support personal repositories for this, only organizations.
#https://www.terraform.io/docs/providers/github/r/repository_webhook.html
#"This resource cannot currently be used to manage webhooks for personal repositories, outside of organizations"
#There is a feature request here, and workaround.
#https://github.com/terraform-providers/terraform-provider-github/issues/45

# Wire the CodePipeline webhook into a GitHub repository.
#resource "github_repository_webhook" "bar" {
#  #test
#  repository = "${github_repository.repo.name}"
#  #repository = "onica-app"
#  configuration {
#    url          = "${aws_codepipeline_webhook.bar.url}"
#    content_type = "json"
#    insecure_ssl = true
#    secret       = "${local.webhook_secret}"
#  }
#
#  events = ["push"]
#}
