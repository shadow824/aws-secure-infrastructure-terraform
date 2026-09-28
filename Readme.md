# Cloud Small Infrastructure

Terraform infrastructure for the portfolio/web application architecture.

## Architecture

- VPC `10.0.0.0/16`
- Public subnet `10.0.1.0/24` for EC2 application server
- Private subnets `10.0.2.0/24` and `10.0.3.0/24` for RDS
- Internet Gateway and public route table
- MySQL RDS, not publicly accessible
- S3 private storage with encryption, versioning, and public-access blocking
- EC2 IAM role with SSM access and scoped S3 access
- Lambda health check with CloudWatch logs
- CloudWatch alarms for EC2 CPU, RDS CPU, and Lambda errors
- Existing tools VPC and VPC peering are preserved

## Before deployment

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`.
2. Replace `db_password` with a strong local password.
3. Configure AWS credentials using your normal AWS authentication method.
4. Run `terraform init` and `terraform plan` from the `terraform` directory.
5. Apply with `terraform apply` after reviewing the plan.

## Portfolio deployment

The EC2 instance installs Nginx and creates a small placeholder page so the infrastructure is immediately testable. Replace the placeholder with the supplied portfolio frontend/backend deployment when ready.

The RDS endpoint is private and is intended to be consumed by the application through the VPC. The S3 bucket is private and available to the EC2 instance through its IAM role.
