variable "server_port" {
	description = "The port for Web server"
	type = number
	default = 8080
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

variable "custom_tags" {
	description = "Custom tags to set on the Instances in the ASG"
	type = map(string)
	default = {}
}

variable "enable_autoscaling" {
	description = "If set to true enable autoscaling"
	type = bool
}

variable "ami" {
	description = "The AMI to run in the cluster"
	type = string
	default = "ami-0e84e211558a022c0"
}

variable "server_text" {
	description = "The text the webserver should return"
	type = string
	default = "Hello, world"
}

variable "subnet_ids" {
	description = "The subnet IDs to deploy to"
	type = list(string)
}

variable "target_group_arns" {
	description = "The ARNs of ELB target groups in which to register instances"
	type = list(string)
	default = []
}

variable "health_check_type" {
	description = "The type of health check to perform. Must be one of: EC2, ELB."
	type = string
	default = "EC2"
}

variable "user_data" {
	description = "The User Data script to tun in each Instance at boot"
	type = string
	default = ""
}
