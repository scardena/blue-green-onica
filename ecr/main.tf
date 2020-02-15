provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "limoneno-backend" {
  name                 = "limoneno-backend"

}

resource "aws_ecr_repository" "limoneno-frontend" {
  name                 = "limoneno-frontend"

}
