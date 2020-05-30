output "asg_name" {
	description = "The name of the Auto Scaling Group"
	value = aws_autoscaling_group.my_asg.name
}

output "instance_security_geoup_id" {
	description = "The ID of the EC2 Instance Security Group"
	value = aws_security_group.instance.id
}
