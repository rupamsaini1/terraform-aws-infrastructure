variable "project_name" {
   type = string
   description = "project name used for naming resources"
}

variable "environment" {
   type = string
   description = "Deployment environment (dev, staging, prod)"
}

variable "vpc_cidr" {
   type = string
   description = "CIDR block for vpc"
}