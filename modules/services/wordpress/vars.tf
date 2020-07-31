variable "db_remote_state_bucket" {
	description = "The name of the S3 bucket for the database's remote state"
	type = string
}

variable "db_remote_state_key" {
	description = "The path for the database's remote state in S3"
	type = string
}

variable "environment" {
	description = "The name of the environment we're deploying to"
	type = string
}

variable "custom_tags" {
	description = "Custom tags to set on the Instances in the ASG"
	type = map(string)
	default = {}
}

variable "ami" {
	description = "The AMI to run in the cluster"
	type = string
	default = "ami-0e84e211558a022c0"
}

variable "cluster_name" {
	description = "The name to use for all the cluster resources"
	type = string
}

variable "min_size" {
	description = "The minimum number of instances"
	type = number
	default = 1
}

variable "desired_capacity" {
	description = "The desired number of instances"
	type = number
	default = 1
}

variable "max_size" {
	description = "The maximum number of instances"
	type = number
	default = 5
}

variable "instance_type" {
	description = "The type of the instance"
	type = string
}

variable "server_port" {
	description = "The port for Web server"
	type = number
	default = 80
}

variable "ssl_policy" {
	description = "SSL policy for ALB listener"
}

variable "certificate_arn" {
	description = "SSL certificate ARN for ALB listener"
}

variable "key_name" {
	description = "The name of the key to use for instance access"
	type = string
}

variable "health_check_type" {
	description = "Type of the health check: EC2 or ELB"
	type = string
}

variable "db_password" {
	description = "DB password"
	type = string
}

variable "alarms_email" {
	description = "Email for alarms"
	type = string
}