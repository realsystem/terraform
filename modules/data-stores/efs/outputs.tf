output "efs_mnt_dns" {
  description = "DNS mount target names"
  value       = "${aws_efs_mount_target.wp_efs_mnt.0.dns_name}"
}