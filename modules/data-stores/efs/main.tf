locals {
	nfs_port = 2049
	any_port = 0
	any_protocol = -1
	tcp_protocol = "tcp"
	all_ips = ["0.0.0.0/0"]
}

resource "aws_security_group" "efs" {
	name = var.efs_name
}

resource "aws_security_group_rule" "allow_nfs_inbound" {
	type = "ingress"
	security_group_id = aws_security_group.efs.id
	from_port = local.nfs_port
	to_port = local.nfs_port
	protocol = local.tcp_protocol
	source_security_group_id = var.instance_security_group_id
}

resource "aws_security_group_rule" "allow_all_outbound" {
	type = "egress"
	security_group_id = aws_security_group.efs.id
	from_port = local.any_port
	to_port = local.any_port
	protocol = local.any_protocol
	cidr_blocks = local.all_ips
}

resource "aws_efs_file_system" "wp_efs" {
  creation_token = var.efs_name
  encrypted = true
}

resource "aws_efs_mount_target" "wp_efs_mnt" {
  count = length(var.aws_subnets)

  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = element(var.aws_subnets, count.index)
  security_groups = [
    aws_security_group.efs.id,
  ]
}
