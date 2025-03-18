module "aws-prod"{
    source = "../../infra"
    instancia = "t2.micro"
    regiao_aws = "us-east-2"
    chave = "IaC-Prod"
    grupoDeSeguranca = "Prod"
    minimo = 1
    maximo = 10
    nomeGrupo = "Prod"
}
