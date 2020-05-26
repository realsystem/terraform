provider "aws" {
	region = "us-east-2"
}

resource "aws_db_instance" "my_db" {
	identifier_prefix = "terraform-up-and-running"
	engine = "mysql"
	allocated_storage = 10
	instance_class = "db.t2.micro"
	skip_final_snapshot = true
	name = "example_db"
	username = "admin"
	password = var.db_password
	//password = data.aws_secretsmanager_secret_version.db_password.secret_string
}

/*data "aws_secretsmanager_secret_version" "db_password" {
	secret_id = "mysql-master-password-stage"
}*/

terraform {
	backend "s3" {
		bucket = "rs-terraform-up-and-running-state"
		key = "stage/data-stores/mysql/terraform.tfstate"
		region = "us-east-2"
		dynamodb_table = "rs-terraform-up-and-running-locks"
		encrypt = true
	}
}
