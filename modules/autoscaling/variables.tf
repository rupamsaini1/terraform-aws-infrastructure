variable "name"{
    type = string
    description = "Name"
}

variable "launch_template_id" {
    type = string
    description = "launch template ID"
}

variable "launch_template_version" {
    type = number
    description = "launch template version"
}

variable "subnet_ids" {
    type = list(string)
    description = "Subnet ID"
}

variable "desired_capacity" {
    type = number
    description = "Desired capacity"
}

variable "min_size" {
    type = number
    description = "Min Capacity"
}

variable "max_size" {
    type = number
    description = "Max Capacity"
}

variable "target_group_arns" {
    type = list(string)
    description = "Target Group ARN"
}

variable "health_check_type" {
  default = "ELB"
}

variable "tags" {
  default = {}
}