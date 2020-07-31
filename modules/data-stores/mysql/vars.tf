variable "cluster_name" {
	description = "The name to use for all the cluster resources"
	type = string
}

variable "db_name" {
	description = "Mysql name"
	type = string
}

variable "db_instance_class" {
	description = "Mysql instance type"
	type = string
}

variable "db_username" {
	description = "Mysql username"
	type = string
}

variable "db_password" {
	description = "Mysql password"
	type = string
}

variable "db_storage" {
	description = "Amount of storage allocated for DB in Gb"
	type = number
	default = 10
}

variable "db_az" {
	description = "Mysql instance AZ"
	type = string
}
