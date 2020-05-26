provider "aws" {
	version = "~> 2.63"
    region = "us-east-2"
}

module "webserver_cluster" {
	source = "../../../modules/services/webserver-cluster"
	cluster_name = "webservers-stage"
	db_remote_state_bucket = "rs-terraform-up-and-running-state"
	db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}

terraform {
	backend "s3" {
		bucket = "rs-terraform-up-and-running-state"
		key = "stage/services/webserver-cluster/terraform.tfstate"
		region = "us-east-2"
		dynamodb_table = "rs-terraform-up-and-running-locks"
		encrypt = true
	}
}
