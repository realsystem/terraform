output "address" {
	description = "Connect to the database at this endpoint"
	value = module.webserver_db.my_db_address
}

output "port" {
	description = "The port the database is listening on"
	value = module.webserver_db.my_db_port
}
