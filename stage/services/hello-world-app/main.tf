provider "aws" {
	version = "~> 2.0"
    region = "us-east-2"
}

module "hello_world_app" {
	source = "git@github.com:realsystem/terraform.git//modules/services/hello-world-app?ref=v0.0.1"
	cluster_name = "webservers-stage"
	environment = "stage"
	instance_type = "t2.micro"
	min_size = 1
	max_size = 5
	desired_capacity = 1
	db_remote_state_bucket = "rs-terraform-up-and-running-state"
	db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
	custom_tags = {
		Owner = "Team A"
		DeployedBy = "Terraform"
	}
	enable_autoscaling = true
	ami = "ami-0e84e211558a022c0"
	server_text = "Overlanding Project Lab v2"
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
