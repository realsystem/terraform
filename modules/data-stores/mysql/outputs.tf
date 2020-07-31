output "my_db_address" {
	description = "Connect to the database at this endpoint"
	value = aws_db_instance.my_db.address
}

output "my_db_port" {
	description = "The port the database is listening on"
	value = aws_db_instance.my_db.port
}

output "my_db_name" {
	description = "The name of the database"
	value = aws_db_instance.my_db.name
}

output "my_db_username" {
	description = "The name of the user to access database"
	value = aws_db_instance.my_db.username
}

output "my_db_az" {
	description = "The name of the AZ where database instance located"
	value = aws_db_instance.my_db.availability_zone
}
