output "alb_dns_name" {
  description = "The domain name of the Load Balancer"
  value       = module.wp.alb_dns_name
}
