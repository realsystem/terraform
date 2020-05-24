variable "server_port" {
	description = "The port for Web server"
	type = number
	default = 8080
}

provider "aws" {
	version = "~> 2.63"
    region = "us-west-1"
}

resource "aws_security_group" "instance" {
	name = "server-instance"
	ingress {
		from_port = var.server_port
		to_port = var.server_port
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "alb" {
	name = "server-alb"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

output "alb_dns_name" {
	description = "The domain name of the load balancer"
	value = aws_lb.my_lb.dns_name
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

resource "aws_launch_configuration" "my_asg_template" {
	image_id = "ami-075fd582acf0c0128"
	instance_type = "t2.micro"
	lifecycle {
		create_before_destroy = true
	}
	security_groups = [aws_security_group.instance.id]
	user_data = <<-EOF
				#!/bin/bash
				echo "Overlanding Project Lab" > index.html
				nohup busybox httpd -f -p ${var.server_port} &
				EOF
}

resource "aws_autoscaling_group" "my_asg" {
	launch_configuration = aws_launch_configuration.my_asg_template.name
	vpc_zone_identifier = data.aws_subnet_ids.default.ids
	min_size = 2
	max_size = 10
	target_group_arns = [aws_lb_target_group.asg_target.arn]
	health_check_type = "ELB"
	tag {
		key = "Name"
		value = "wp-asg"
		propagate_at_launch = true
	}
}

resource "aws_lb" "my_lb" {
	name = "wp-asg"
	load_balancer_type = "application"
	security_groups = [aws_security_group.alb.id]
	subnets = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.my_lb.arn
	port = 80
	protocol = "HTTP"
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
	name = "wp-asg"
	port = var.server_port
	protocol = "HTTP"
	vpc_id = data.aws_vpc.default.id
	health_check {
		path = "/"
		protocol = "HTTP"
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
