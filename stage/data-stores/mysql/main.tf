provider "aws" {
	version = "~> 2.63"
	region = "us-east-2"
}

module "webserver_db" {
	source = "../../../modules/data-stores/mysql"
	cluster_name = "webservers-stage"
	db_name = "wordpress"
	db_username = "wordpress"
	db_password = var.db_password
	db_instance_class = "db.t2.micro"
}

terraform {
	backend "s3" {
		bucket = "rs-terraform-up-and-running-state"
		key = "stage/data-stores/mysql/terraform.tfstate"
		region = "us-east-2"
		dynamodb_table = "rs-terraform-up-and-running-locks"
		encrypt = true
	}
}
