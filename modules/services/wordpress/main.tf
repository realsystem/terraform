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

data "aws_subnet" "default" {
	vpc_id = data.aws_vpc.default.id
	# TODO
	availability_zone = data.terraform_remote_state.my_db_state.outputs.db_az
}

data "aws_subnet_ids" "default" {
	vpc_id = data.aws_vpc.default.id
}

resource "aws_default_security_group" "default" {
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port       = local.db_port
        to_port         = local.db_port
        protocol        = "tcp"
        security_groups = [module.asg.instance_security_group_id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "terraform_remote_state" "my_db_state" {
	backend = "s3"
	config = {
		bucket = var.db_remote_state_bucket
		key    = var.db_remote_state_key
		region = "us-east-2"
	}
}

data "template_file" "user_data" {
	template = file("${path.module}/user-data.sh")
	vars = {
		server_port = var.server_port
		efs_id      = module.efs_data.efs_id
		db_address  = data.terraform_remote_state.my_db_state.outputs.address
        db_port     = data.terraform_remote_state.my_db_state.outputs.port
        db_password = var.db_password
        db_name     = data.terraform_remote_state.my_db_state.outputs.db_name
        db_username = data.terraform_remote_state.my_db_state.outputs.db_username
	}
}

resource "aws_lb_target_group" "asg_target" {
	name = "wordpress-${var.environment}"
	port = var.server_port
	protocol = local.http_protocol
	vpc_id = data.aws_vpc.default.id
	health_check {
		path     = "/"
		protocol = local.http_protocol
		matcher  = "200,301,302"
		interval = 30
		timeout  = 3

		healthy_threshold   = 2
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
	aws_subnets = [data.aws_subnet.default.id]
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
	subnet_ids = [data.aws_subnet.default.id]
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

resource "aws_sns_topic" "alarm" {
  name = "alarms-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.alarm.arn} --protocol email --notification-endpoint ${var.alarms_email}"
  }
}