locals {
	http_protocol = "HTTP"
	tcp_protocol = "TCP"
	db_port = 3306
	any_port = 0
	any_protocol = -1
	all_ips = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

resource "aws_default_security_group" "default" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_all_inbound" {
	type = "ingress"
	security_group_id = aws_default_security_group.default.id
	from_port = local.db_port
	to_port = local.db_port
	protocol = local.tcp_protocol
	source_security_group_id = aws_default_security_group.default.id
}

resource "aws_security_group_rule" "allow_instance_inbound" {
	type = "ingress"
	security_group_id = aws_default_security_group.default.id
	from_port = local.db_port
	to_port = local.db_port
	protocol = local.tcp_protocol
	source_security_group_id = module.asg.instance_security_group_id
}

resource "aws_security_group_rule" "allow_all_outbound" {
	type = "egress"
	security_group_id = aws_default_security_group.default.id
	from_port = local.any_port
	to_port = local.any_port
	protocol = local.any_protocol
	cidr_blocks = local.all_ips
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
		db_address = data.terraform_remote_state.my_db_state.outputs.address
        db_port = data.terraform_remote_state.my_db_state.outputs.port
        db_password = var.db_password
        db_name = data.terraform_remote_state.my_db_state.outputs.db_name
        db_username = data.terraform_remote_state.my_db_state.outputs.db_username
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
