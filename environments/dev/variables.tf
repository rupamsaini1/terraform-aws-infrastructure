variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}
variable "ingress_rules" {
  description = "Security Group inbound rule"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
variable "egress_rules" {
  description = "Security Group outbound rule"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "target_group_port" {
  type        = number
  description = "Target Group Port"

}

variable "min_size" {
  type        = number
  description = "min instance in asg"
}

variable "desired_capacity" {
  type        = number
  description = "desired capacity"
}
variable "max_size" {
  type        = number
  description = "max instance size"
}