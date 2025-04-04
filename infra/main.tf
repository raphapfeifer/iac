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
  region  = var.regiao_aws
}

resource "aws_launch_template" "maquina" {
  image_id           = "ami-0cb91c7de36eed2cb"
  instance_type = var.instancia
  key_name = var.chave 
  tags = {
    Name = "Terraform Ansible Python"
  }
  security_group_names = [ var.grupoDeSeguranca ]
  user_data = filebase64("ansible.sh")
}

resource "aws_key_pair" "chaveSSH"{
  key_name = var.chave
  public_key = file("${var.chave}.pub")
}


resource "aws_autoscaling_group" "grupo" {
  availability_zones = [ "${var.regiao_aws}a", "${var.regiao_aws}b" ]
  name = var.nomeGrupo
  max_size = var.maximo
  min_size = var.minimo
  launch_template {
    id = aws_launch_template.maquina.id
    version = "$Latest"
  }
  target_group_arns = [ aws_lb_target_group.alvoLoadBalancer.arn ]
}

resource "aws_default_subnet" "subnet_1"{
  availability_zone =  "${var.regiao_aws}a"
}

resource "aws_default_subnet" "subnet_2"{
  availability_zone =  "${var.regiao_aws}b"
}

resource "aws_lb" "loadBalancer"{
  internal = false
  subnets = [ aws_default_subnet.subnet_1.id,aws_default_subnet.subnet_2.id ]
  security_groups = [aws_security_group.acesso_geral.id]
}

resource "aws_lb_target_group" "alvoLoadBalancer"{
  name = "maquinasAlvo"
  port = "8000"
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
}

resource "aws_lb_listener" "entradaLoadBalancer"{
  load_balancer_arn = aws_lb.loadBalancer.arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer.arn
  }
}

resource "aws_default_vpc" "default"{

}