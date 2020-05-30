output "alb_dns_name" {
	description = "The domain name of the Load Balancer"
	value = module.hello_world_app.alb_dns_name
}
