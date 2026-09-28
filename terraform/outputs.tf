output "vpc_id" {
  description = "ID of the application VPC"
  value       = aws_vpc.Vpc_app_EC2.id
}

output "public_subnet_id" {
  description = "ID of the public application subnet"
  value       = aws_subnet.subnet_app_EC2.id
}

output "private_subnet_ids" {
  description = "IDs of the private RDS subnets"
  value       = [aws_subnet.Subnet_PRV_RDS.id, aws_subnet.Subnet_PRV_RDS2.id]
}

output "ec2_instance_id" {
  description = "ID of the application EC2 instance"
  value       = aws_instance.my_ec2.id
}

output "ec2_public_ip" {
  description = "Public IP address of the application EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the application EC2 instance"
  value       = aws_instance.my_ec2.public_dns
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.app_db.address
}

output "rds_port" {
  description = "RDS database port"
  value       = aws_db_instance.app_db.port
}

output "s3_bucket_name" {
  description = "Name of the private application S3 bucket"
  value       = aws_s3_bucket.app.bucket
}

output "lambda_function_name" {
  description = "Name of the health-check Lambda function"
  value       = aws_lambda_function.app.function_name
}
