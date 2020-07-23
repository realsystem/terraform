provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

locals {
	tcp_protocol = "tcp"
	all_ips = ["0.0.0.0/0"]
	server_port = 80
}

resource "aws_security_group" "instance" {
	name = "example-instance"
	ingress {
		from_port = local.server_port
		to_port = local.server_port
		protocol = local.tcp_protocol
		cidr_blocks = local.all_ips
	}
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

module "efs" {
	source = "../../modules/data-stores/efs"
	instance_security_group_id = aws_security_group.instance.id
	aws_subnets = data.aws_subnet_ids.default.ids
}