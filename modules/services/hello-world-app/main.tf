locals {
	http_port = 80
	any_port = 0
	any_protocol = -1
	tcp_protocol = "tcp"
	http_protocol = "HTTP"
	all_ips = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

data "terraform_remote_state" "my_db_state" {
	backend = "s3"
	config = {
		bucket = var.db_remote_state_bucket
		key = var.db_remote_state_key
		region = "us-east-2"
	}
}

data "template_file" "user_data" {
	template = file("${path.module}/user-data.sh")
	vars = {
		server_port = var.server_port
		db_address = data.terraform_remote_state.my_db_state.outputs.address
		db_port = data.terraform_remote_state.my_db_state.outputs.port
		server_text = var.server_text
	}
}

resource "aws_lb_target_group" "asg_target" {
	name = "hello-world-${var.environment}"
	port = var.server_port
	protocol = local.http_protocol
	vpc_id = data.aws_vpc.default.id
	health_check {
		path = "/"
		protocol = local.http_protocol
		matcher = "200"
		interval = 15
		timeout = 3
		healthy_threshold = 2
		unhealthy_threshold = 2
	}
}

resource "aws_lb_listener_rule" "asg" {
	listener_arn = module.alb.alb_http_listener_arn
	priority = 100
	condition {
		path_pattern {
			values = ["*"]
		}
	}
	action {
		type = "forward"
		target_group_arn = aws_lb_target_group.asg_target.arn
	}
}

module "asg" {
	source = "../../cluster/asg-rolling-deploy"
	cluster_name = "hello-world-${var.environment}"
	ami = var.ami
	user_data = data.template_file.user_data.rendered
	instance_type = var.instance_type
	min_size = var.min_size
	max_size = var.max_size
	enable_autoscaling = var.enable_autoscaling
	subnet_ids = data.aws_subnet_ids.default.ids
	target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type = "ELB"
	custom_tags = var.custom_tags
}

module "alb" {
	source = "../../networking/alb"
	alb_name = "hello-world-${var.environment}"
	subnets_ids = data.aws_subnet_ids.default.ids
}