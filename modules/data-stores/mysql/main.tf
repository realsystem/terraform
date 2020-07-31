resource "aws_db_instance" "my_db" {
	identifier_prefix = "${var.cluster_name}-db"
	engine = "mysql"
	allocated_storage = var.db_storage
	instance_class = var.db_instance_class
	skip_final_snapshot = true
	name = var.db_name
	username = var.db_username
	password = var.db_password
	availability_zone = var.db_az
}
