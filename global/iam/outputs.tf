output "neo_arn" {
	description = "All users"
	value = values(aws_iam_user.test)[*].arn
}

output "for_directive" {
	value = <<EOF
	%{~ for name in var.user_names}
		${name}
	%{~ endfor}
	EOF
}
