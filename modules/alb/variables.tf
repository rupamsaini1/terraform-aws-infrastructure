variable "name" {
  description = "Name of the Application Load Balancer"
  type        = string
}
variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}
variable "security_group_ids" {
  description = "Security groups attached to the ALB"
  type        = list(string)
}
variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}
variable "target_group_port" {
  description = "Target Group port"
  type        = number
}
variable "target_group_protocol" {
  description = "Target Group protocol"
  type        = string
  default     = "HTTP"
}
variable "vpc_id" {
  description = "VPC ID for the Target Group"
  type        = string
}
variable "health_check_path" {
  description = "Health check endpoint"
  type        = string
  default     = "/"
}
variable "tags" {
  description = "Tags to apply to the ALB"
  type        = map(string)
  default     = {}
}
variable "target_group_name" {
  type = string
}