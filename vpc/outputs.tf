output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = values(aws_subnet.private)[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets."
  value       = values(aws_subnet.database)[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group."
  value       = aws_db_subnet_group.this.name
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = values(aws_nat_gateway.this)[*].id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = values(aws_route_table.private)[*].id
}

output "database_route_table_ids" {
  description = "IDs of the database route tables."
  value       = values(aws_route_table.database)[*].id
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the security group used by interface VPC endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint."
  value       = aws_vpc_endpoint.s3.id
}

output "ssm_vpc_endpoint_ids" {
  description = "IDs of the Systems Manager interface VPC endpoints."

  value = {
    ssm         = aws_vpc_endpoint.ssm.id
    ssmmessages = aws_vpc_endpoint.ssm_messages.id
    ec2messages = aws_vpc_endpoint.ec2_messages.id
  }
}

output "ecr_vpc_endpoint_ids" {
  description = "IDs of the Amazon ECR interface VPC endpoints."

  value = {
    api = aws_vpc_endpoint.ecr_api.id
    dkr = aws_vpc_endpoint.ecr_dkr.id
  }
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log."
  value       = aws_flow_log.this.id
}
