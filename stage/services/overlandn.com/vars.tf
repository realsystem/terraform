variable "server_port" {
  description = "The port for Web server"
  type        = number
  default     = 80
}

variable "wp_db_name" {
	description = "The database name for wordpress"
	type = string
	default = "wordpress"
}

variable "wp_db_passwd" {
	description = "The database root password for wordpress"
	type = string
	default = "wordpress"
}

variable "wp_db_user" {
	description = "The database user name for wordpress"
	type = string
	default = "wordpress"
}

variable "wp_db_user_passwd" {
	description = "The database user password for wordpress"
	type = string
	default = "wordpress"
}
