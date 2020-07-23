provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

module "wp" {
  source                 = "../../../modules/services/wordpress"
  cluster_name           = "webservers-stage"
  environment            = "stage"
  instance_type          = "t2.micro"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  db_remote_state_bucket = "rs-terraform-up-and-running-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"
  key_name               = "myvm"
  health_check_type      = "ELB"
  custom_tags = {
    Owner      = "RS"
    DeployedBy = "Terraform"
  }
  enable_autoscaling = true

  ami                = "ami-0f4ee0f926e9f568d"
  server_port        = 80
  server_text        = "Overlanding Project Lab v1"
  ssl_policy         = "ELBSecurityPolicy-2016-08"
  certificate_arn    = "arn:aws:acm:us-east-2:243593776856:certificate/5cef988b-bc15-4747-9a03-efb95cb0e374"

  wp_db_name = var.wp_db_name
  wp_db_passwd = var.wp_db_passwd
  wp_db_user = var.wp_db_user
  wp_db_user_passwd = var.wp_db_user_passwd
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
