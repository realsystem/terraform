locals {
	tcp_protocol = "tcp"
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

resource "aws_launch_configuration" "my_asg_template" {
	image_id = var.ami
	instance_type = var.instance_type
	lifecycle {
		create_before_destroy = true
	}
	security_groups = [aws_security_group.instance.id]
	user_data = var.user_data
}

resource "aws_autoscaling_group" "my_asg" {
	name = "${var.cluster_name}-${aws_launch_configuration.my_asg_template.name}"
	launch_configuration = aws_launch_configuration.my_asg_template.name
	vpc_zone_identifier = var.subnet_ids
	min_size = var.min_size
	max_size = var.max_size
	desired_capacity = var.desired_capacity
	target_group_arns = var.target_group_arns
	health_check_type = var.health_check_type
	min_elb_capacity = var.min_size
	lifecycle {
		create_before_destroy = true
	}
	tag {
		key = "Name"
		value = "${var.cluster_name}-asg"
		propagate_at_launch = true
	}
	dynamic "tag" {
		for_each = var.custom_tags
		content {
			key = tag.key
			value = tag.value
			propagate_at_launch = true
		}
	}
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
	alarm_name = "${var.cluster_name}-high-cpu-utilization"
	namespace = "AWS/EC2"
	metric_name = "CPUUtilization"
	dimensions = {
		AutoScalingGroupName = aws_autoscaling_group.my_asg.name
	}
	comparison_operator = "GreaterThanThreshold"
	evaluation_periods = 1
	period = 300
	statistic = "Average"
	threshold = 90
	unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
	count = format("%.1s", var.instance_type) == "t" ? 1 : 0
	alarm_name = "${var.cluster_name}-low-cpu-credit-balance"
	namespace = "AWS/EC2"
	metric_name = "CPUCreditBalance"
	dimensions = {
		AutoScalingGroup = aws_autoscaling_group.my_asg.name
	}
	comparison_operator = "LessThanThreshold"
	evaluation_periods = 1
	period = 300
	statistic = "Minimum"
	threshold = 10
	unit = "Count"
}
