provider "aws" {
	version = "~> 2.0"
	region = "us-east-2"
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

module "asg" {
	source = "../../modules/cluster/asg-rolling-deploy"
	cluster_name = "test_asg"
	ami = "ami-0c55b159cbfafe1f0"
	instance_type = "t2.micro"
	min_size = 1
	max_size = 1
	subnet_ids = data.aws_subnet_ids.default.ids
	user_data = "echo test"
}

terraform {
	required_version = ">= 0.12, < 0.13"
}
