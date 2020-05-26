locals {
	http_port = 80
	any_port = 0
	any_protocol = -1
	tcp_protocol = "tcp"
	http_protocol = "HTTP"
	all_ips = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance" {
	name = "${var.cluster_name}-instance"
	ingress {
		from_port = var.server_port
		to_port = var.server_port
		protocol = local.tcp_protocol
		cidr_blocks = local.all_ips
	}
}

resource "aws_security_group" "alb" {
	name = "${var.cluster_name}-alb"
	ingress {
		from_port = local.http_port
		to_port = local.http_port
		protocol = local.tcp_protocol
		cidr_blocks = local.all_ips
	}
	egress {
		from_port = local.any_port
		to_port = local.any_port
		protocol = local.any_protocol
		cidr_blocks = local.all_ips
	}
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
	template = file("user-data.sh")
	vars = {
		server_port = var.server_port
		db_address = data.terraform_remote_state.my_db_state.outputs.address
		db_port = data.terraform_remote_state.my_db_state.outputs.port
	}
}

resource "aws_launch_configuration" "my_asg_template" {
	image_id = "ami-0e84e211558a022c0"
	instance_type = "t2.micro"
	lifecycle {
		create_before_destroy = true
	}
	security_groups = [aws_security_group.instance.id]
	user_data = data.template_file.user_data.rendered
}

resource "aws_autoscaling_group" "my_asg" {
	launch_configuration = aws_launch_configuration.my_asg_template.name
	vpc_zone_identifier = data.aws_subnet_ids.default.ids
	min_size = 1
	max_size = 5
	desired_capacity = 1
	target_group_arns = [aws_lb_target_group.asg_target.arn]
	health_check_type = "ELB"
	tag {
		key = "Name"
		value = "${var.cluster_name}-asg"
		propagate_at_launch = true
	}
}

resource "aws_lb" "my_lb" {
	name = "${var.cluster_name}-asg"
	load_balancer_type = "application"
	security_groups = [aws_security_group.alb.id]
	subnets = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.my_lb.arn
	port = local.http_port
	protocol = local.http_protocol
	default_action {
		type = "fixed-response"
		fixed_response {
			content_type = "text/plain"
			message_body = "404: page not found"
			status_code = 404
		}
	}
}

resource "aws_lb_target_group" "asg_target" {
	name = "${var.cluster_name}-asg"
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
	listener_arn = aws_lb_listener.http.arn
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
