provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "onica_app" {
  name                 = "onica_app"

}

