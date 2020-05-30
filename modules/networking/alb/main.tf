resource "aws_security_group" "alb" {
	name = var.alb_name
}

resource "aws_security_group_rule" "allow_http_inbound" {
	type = "ingress"
	security_group_id = aws_security_group.alb.id
	from_port = local.http_port
	to_port = local.http_port
	protocol = local.tcp_protocol
	cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
	type = "egress"
	security_group_id = aws_security_group.alb.id
	from_port = local.any_port
	to_port = local.any_port
	protocol = local.any_protocol
	cidr_blocks = local.all_ips
}

resource "aws_lb" "my_lb" {
	name = var.alb_name
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