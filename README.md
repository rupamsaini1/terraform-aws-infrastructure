# terraform-aws-infrastructure

Terraform configuration for a modular AWS environment: a VPC with public/private subnets, an Application Load Balancer, a launch template, and an Auto Scaling Group behind it. Includes a separate bootstrap stack for creating the remote state backend (S3 + DynamoDB).

## Architecture

```
                         Internet
                            |
                     Internet Gateway
                            |
                    ┌───────────────┐
                    │  Public subnets │  (per AZ)
                    └───────────────┘
                     |            |
                 NAT Gateway    ALB (security group)
                     |            |
                    ┌───────────────┐
                    │ Private subnets │  (per AZ)
                    └───────────────┘
                            |
                  Auto Scaling Group
                  (EC2 from Launch Template)
```

- **VPC**: one VPC with a public and private subnet per AZ, an Internet Gateway, one NAT Gateway per public subnet, and route tables/associations for both tiers.
- **Security Group**: single security group with configurable ingress/egress rules, shared by the ALB and the EC2 instances.
- **ALB**: public-facing Application Load Balancer with an HTTP listener forwarding to a target group.
- **Launch Template**: defines the EC2 instance configuration (AMI, instance type, key pair, encrypted root volume) used by the ASG.
- **Auto Scaling Group**: launches instances from the launch template into the private subnets, registered against the ALB target group, with rolling instance refresh.

## Repository structure

```
.
├── bootstrap/            # One-time setup: S3 state bucket + DynamoDB lock table
├── backend/              # Backend config (.hcl) files used with `terraform init -backend-config=...`
├── environments/
│   ├── dev/              # Dev environment root module (wires the modules below together)
│   ├── staging/          # Reserved for a staging environment
│   └── prod/             # Reserved for a production environment
└── modules/
    ├── vpc/              # VPC, subnets, IGW, NAT gateways, route tables
    ├── security-group/   # Generic security group with dynamic ingress/egress rules
    ├── alb/               # Application Load Balancer + target group + HTTP listener
    ├── launch-template/  # EC2 launch template
    └── autoscaling/      # Auto Scaling Group
```

Only `dev` is currently implemented; `staging` and `prod` are empty placeholders following the same pattern.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform) >= 1.13.0
- AWS provider `~> 6.0`
- An AWS account with credentials configured under a named CLI profile (`aws configure --profile <profile>`)

## Getting started

### 1. Bootstrap the remote state backend

Creates the S3 bucket and DynamoDB table used to store and lock Terraform state for every other stack.

```bash
cd bootstrap
terraform init
terraform apply \
  -var="aws_region=<region>" \
  -var="aws_profile=<profile>" \
  -var="project_name=<project>"
```

Note the `state_bucket` and `lock_table` outputs — they should match the values in `backend/bootstrap.hcl` and any per-environment backend config you create.

### 2. Deploy an environment (e.g. `dev`)

Each environment has its own partial S3 backend config in `backend/<env>.hcl`, keyed by environment (e.g. `backend/dev.hcl` uses key `dev/terraform.tfstate`) so every environment gets its own state file in the shared bootstrap bucket/lock table.

```bash
cd environments/dev
terraform init -backend-config=../../backend/dev.hcl
terraform plan
terraform apply
```

Each environment expects its own `terraform.tfvars` (not committed — see `.gitignore`). Example:

```hcl
aws_region  = "ap-south-1"
aws_profile = "terraform"

project_name = "myapp"
environment  = "dev"

vpc_cidr              = "10.0.0.0/16"
availability_zones     = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]

key_name      = "my-key"
instance_type = "t3.micro"

target_group_port = 80

min_size         = 2
desired_capacity = 2
max_size         = 4

ingress_rules = [
  { description = "HTTP",  from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
  { description = "HTTPS", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
]

egress_rules = [
  { description = "Allow all outbound", from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] },
]
```

After apply, the ALB's public DNS name is available via the `alb_dns_name` output.

## Modules

| Module | Purpose | Key outputs |
|---|---|---|
| `vpc` | VPC, public/private subnets, IGW, NAT gateways, route tables | `vpc_id`, `public_subnet_ids`, `private_subnet_ids` |
| `security-group` | Security group with dynamic ingress/egress rule lists | `security_group_id` |
| `alb` | Application Load Balancer, target group, HTTP listener | `dns_name`, `target_group_arn` |
| `launch-template` | EC2 launch template with encrypted root volume | `launch_template_id`, `latest_version` |
| `autoscaling` | Auto Scaling Group with rolling instance refresh | `autoscaling_group_name`, `autoscaling_group_arn` |

## State management

- Remote state is backed by S3 with DynamoDB locking, provisioned by `bootstrap/`.
- Each environment gets its own state file in the shared bucket (e.g. `dev/terraform.tfstate`), keyed via its own `backend/<env>.hcl` — see [Deploy an environment](#2-deploy-an-environment-eg-dev).
- The state bucket has versioning enabled, default SSE-AES256 encryption, and all public access blocked, so every environment's state inherits the same protections automatically.
- `*.tfstate`, `*.tfvars`, and `.terraform/` are gitignored — they are not, and should not be, committed.

## Notes

- The `dev` environment currently opens SSH (22) to `0.0.0.0/0` in its example tfvars — tighten this to a known CIDR before using it beyond a lab/demo setting.
- ASG instances launch into private subnets with outbound internet access via NAT Gateway; the ALB sits in the public subnets.
