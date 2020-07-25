output "address" {
	description = "Connect to the database at this endpoint"
	value = module.webserver_db.my_db_address
}

output "port" {
	description = "The port the database is listening on"
	value = module.webserver_db.my_db_port
}

output "db_name" {
	description = "The name of the database"
	value = module.webserver_db.my_db_name
}

output "db_username" {
	description = "The name of the user to access database"
	value = module.webserver_db.my_db_username
}
