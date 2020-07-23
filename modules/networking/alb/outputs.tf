output "alb_dns_name" {
	description = "The domain name of the load balancer"
	value = aws_lb.my_lb.dns_name
}

output "alb_https_listener_arn" {
	description = "The ARN of the HTTPS listener"
	value = aws_lb_listener.https.arn
}

output "alb_security_group_id" {
	description = "The ALB security group ID"
	value = aws_security_group.alb.id
}
