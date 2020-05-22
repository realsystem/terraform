provider "aws" {
	version = "~> 2.63"
    region = "us-west-1"
}

resource "aws_instance" "my_aws" {
	ami = "ami-075fd582acf0c0128"
	instance_type = "t2.micro"
	tags = {
		Name = "Server"
	}
}