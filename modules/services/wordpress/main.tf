locals {
	http_protocol = "HTTP"
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
		efs_data = module.efs_data.efs_mnt_dns
	}
}

resource "aws_lb_target_group" "asg_target" {
	name = "wordpress-${var.environment}"
	port = var.server_port
	protocol = local.http_protocol
	vpc_id = data.aws_vpc.default.id
	health_check {
		path = "/"
		protocol = local.http_protocol
		matcher = "200,301,302"
		interval = 30
		timeout = 3
		healthy_threshold = 2
		unhealthy_threshold = 2
	}
}

resource "aws_lb_listener_rule" "asg" {
	listener_arn = module.alb.alb_https_listener_arn
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

module "efs_data" {
	source = "../../data-stores/efs"
	instance_security_group_id = module.asg.instance_security_group_id
	aws_subnets = data.aws_subnet_ids.default.ids
	efs_name = "efs_data"
}

module "asg" {
	source = "../../cluster/asg-rolling-deploy"
	cluster_name = "wordpress-${var.environment}"
	ami = var.ami
	user_data = data.template_file.user_data.rendered
	instance_type = var.instance_type
	min_size = var.min_size
	max_size = var.max_size
	desired_capacity = var.desired_capacity
	enable_autoscaling = var.enable_autoscaling
	subnet_ids = data.aws_subnet_ids.default.ids
	target_group_arns = [aws_lb_target_group.asg_target.arn]
	health_check_type = var.health_check_type
	custom_tags = var.custom_tags
	key_name = var.key_name
	alb_security_group_id = module.alb.alb_security_group_id
}

module "alb" {
	source = "../../networking/alb"
	alb_name = "wordpress-${var.environment}"
	subnet_ids = data.aws_subnet_ids.default.ids
	ssl_policy = var.ssl_policy
	certificate_arn = var.certificate_arn
}
