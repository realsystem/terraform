provider "aws" {
  region = "us-west-1"
}

locals {
	ssh_port = 22
	server_port = 80
	tcp_protocol = "tcp"
	any_port = 0
	any_protocol = -1
	all_ips = ["0.0.0.0/0"]
	wp_db_name = "wordpress"
	wp_db_passwd = "wordpress"
	wp_db_user = "wordpress"
	wp_db_user_passwd = "wordpress"
	server_text = "hello"
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnet" "default" {
	availability_zone = "us-west-1a"
}

resource "aws_security_group" "instance" {
	name = "dev-instance"
}

resource "aws_security_group_rule" "allow_server_inbound" {
	type = "ingress"
	security_group_id = aws_security_group.instance.id
	from_port = local.server_port
	to_port = local.server_port
	protocol = local.tcp_protocol
	cidr_blocks = local.all_ips
}

#TODO
resource "aws_security_group_rule" "allow_ssh_inbound" {
	type = "ingress"
	security_group_id = aws_security_group.instance.id
	from_port = local.ssh_port
	to_port = local.ssh_port
	protocol = local.tcp_protocol
	cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
	type = "egress"
	security_group_id = aws_security_group.instance.id
	from_port = local.any_port
	to_port = local.any_port
	protocol = local.any_protocol
	cidr_blocks = local.all_ips
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "user_data" {
	template = file("user-data.sh")
	vars = {
		server_port = local.server_port
		server_text = local.server_text
		wp_db_name = local.wp_db_name
		wp_db_passwd = local.wp_db_passwd
		wp_db_user = local.wp_db_user
		wp_db_user_passwd = local.wp_db_user_passwd
	}
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "dev"
  }
  security_groups = [aws_security_group.instance.name]
  key_name = "devvm"
  user_data = data.template_file.user_data.rendered
}