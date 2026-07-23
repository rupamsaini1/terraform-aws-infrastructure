output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.this.id
}
output "latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.this.latest_version
}