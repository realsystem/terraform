variable "alb_name" {
	description = "The name to use for this ALB"
	type = string
}

variable "subnet_ids" {
	description = "The subnet IDs to deploy to"
	type = list(string)
}

variable "ssl_policy" {
	description = "SSL policy for ALB listener"
}

variable "certificate_arn" {
	description = "SSL certificate ARN for ALB listener"
}
