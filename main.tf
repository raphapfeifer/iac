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
  #user_data = <<-EOF
  #            #!/bin/bash
  #            cd /home/ubuntu
  #            echo "<h1>Feito com Terraform</h1>" > index.html
  #            nohup busybox httpd -f -p 8080 & 
  #            EOF

  tags = {
    Name = "Segunda instancia"
  }
}