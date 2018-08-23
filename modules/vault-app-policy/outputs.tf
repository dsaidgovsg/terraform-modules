output "app_policy" {
  description = "Name of Application level policy"
  value       = "${local.app_policy_name}"
}

output "app_rendered_content" {
  description = "Vault policy content at Application level"
  value       = "${data.template_file.app_readonly.rendered}"
}

output "dev_policy" {
  description = "Name of Developer level policy"
  value       = "${local.dev_policy_name}"
}

output "dev_rendered_content" {
  description = "Vault policy content at Developer level"
  value       = "${data.template_file.app_read_write.rendered}"
}
