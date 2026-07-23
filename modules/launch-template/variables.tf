variable "name" {
  type        = string
  description = "Name of Name of the Launch Template"
}
variable "ami_id" {
  type        = string
  description = "AMI ID to use for the Launch Template"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "security_group_ids" {
  type        = list(string)
  description = "IDs for security group"
}
variable "key_name" {
  type        = string
  default     = null
  description = "EC2 instance Key Name"
}
variable "user_data" {
  type        = string
  default     = null
  description = "User data script executed during instance launch"
}
variable "root_volume_size" {
  type        = number
  default     = 20
  description = "root volume of EC2"
}
variable "root_volume_type" {
  type        = string
  default     = "gp3"
  description = "Rott volume type of EC2 Instance"
}
variable "tags" {
  description = "Tags to apply to the EC2"
  type        = map(string)
  default     = {}
}
variable "iam_instance_profile" {
  type        = string
  default     = null
  description = "IAM instance profile to attach to the EC2 instance"
}