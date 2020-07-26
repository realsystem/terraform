provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "wp" {
  source                 = "../../../modules/services/wordpress"
  cluster_name           = "webservers-stage"
  environment            = "stage"
  instance_type          = "t2.micro"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  db_password            = var.db_password
  db_remote_state_bucket = "rs-terraform-up-and-running-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"
  key_name               = "myvm"
  health_check_type      = "EC2"
  custom_tags = {
    Owner      = "RS"
    DeployedBy = "Terraform"
  }

  ami                = data.aws_ami.ubuntu.id
  server_port        = 80
  ssl_policy         = "ELBSecurityPolicy-2016-08"
  certificate_arn    = "arn:aws:acm:us-east-2:243593776856:certificate/5cef988b-bc15-4747-9a03-efb95cb0e374"
}

terraform {
  backend "s3" {
    bucket         = "rs-terraform-up-and-running-state"
    key            = "stage/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "rs-terraform-up-and-running-locks"
    encrypt        = true
  }
}
