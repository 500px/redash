output "role_arn" {
  description = "ARN of role to assign to the pods for this service"
  value       = "${module.redash_role.arn}"
}

output "role_name" {
  description = "Name of role to assign to the pods for this service"
  value       = "${module.redash_role.name}"
}
