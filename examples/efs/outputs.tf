output "efs_dns_name" {
	description = "The name of the EFS target mount"
	value = module.efs.efs_mnt_dns
}