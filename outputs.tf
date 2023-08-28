output "json_config" {
  value       = local.json_config_content
  sensitive   = true
  description = <<-EOT
    The generated config formatted as json.
  EOT
}
output "yaml_config" {
  value       = local.yaml_config_content
  sensitive   = true
  description = <<-EOT
    The generated config formatted as yaml.
  EOT
}
