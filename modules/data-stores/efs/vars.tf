variable "instance_security_group_id" {
	description = "Security group ID for instances which allowed to use EFS"
	type = string
}

variable "aws_subnets" {
	description = "List of all subnets in VPC"
	type = list
}

variable "efs_name" {
	description = "EFS unique name"
	type = string
}
