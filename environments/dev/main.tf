data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
module "vpc" {
  source = "../../modules/vpc"


  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_group" {
  source = "../../modules/security-group"

  name          = "${var.project_name}-${var.environment}-sg"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  description   = "Security group for ${var.project_name}"
}

module "launch_template" {
  source = "../../modules/launch-template"

  name          = "${var.project_name}-${var.environment}-lt"
  instance_type = var.instance_type
  ami_id        = data.aws_ami.amazon_linux.id
  key_name      = var.key_name

  security_group_ids = [
    module.security_group.security_group_id
  ]
}

module "alb" {
  source = "../../modules/alb"

  name              = "${var.project_name}-${var.environment}-alb"
  target_group_name = "${var.project_name}-${var.environment}-tg"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  target_group_port = var.target_group_port

  security_group_ids = [
    module.security_group.security_group_id
  ]
}

module "asg" {
  source = "../../modules/autoscaling"

  name = "${var.project_name}-${var.environment}-asg"

  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = module.launch_template.latest_version

  target_group_arns = [
    module.alb.target_group_arn
  ]

  subnet_ids = module.vpc.private_subnet_ids

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
}