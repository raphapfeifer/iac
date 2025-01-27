terraform {
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }

    required_version = ">= 0.14.9"
}

provider "aws" {
  region  = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"
  key_name = "iac-alura"

  tags = {
    Name = "Primeira Instancia"
  }
}