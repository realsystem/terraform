output "my_db_address" {
	description = "Connect to the database at this endpoint"
	value = aws_db_instance.my_db.address
}

output "my_db_port" {
	description = "The port the database is listening on"
	value = aws_db_instance.my_db.port
}
