variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
}
variable "project_name" {
  description = "Project name used for naming and tagging AWS resources."
  type        = string
}
variable "aws_region" {
  description = "AWS region where resources will be deployed."
  type        = string
}
variable "vpc_cidr" {
  description = "AWS VPC cidr block"
  type        = string
}
