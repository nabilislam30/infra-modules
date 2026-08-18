# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group."
  value       = aws_security_group.alb.id
}

# -----------------------------------------------------------------------------
# Compute
# -----------------------------------------------------------------------------

output "compute_security_group_id" {
  description = "ID of the compute instance security group."
  value       = aws_security_group.compute.id
}

output "instance_role_arn" {
  description = "ARN of the IAM role used by compute instances."
  value       = aws_iam_role.compute.arn
}

# -----------------------------------------------------------------------------
# Launch Template
# -----------------------------------------------------------------------------

output "launch_template_id" {
  description = "ID of the compute launch template."
  value       = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  description = "Latest version of the compute launch template."
  value       = aws_launch_template.this.latest_version
}

# -----------------------------------------------------------------------------
# Auto Scaling Group
# -----------------------------------------------------------------------------

output "autoscaling_group_name" {
  description = "Name of the compute Auto Scaling Group."
  value       = aws_autoscaling_group.this.name
}

# -----------------------------------------------------------------------------
# Target Group
# -----------------------------------------------------------------------------

output "target_group_arn" {
  description = "ARN of the Application Load Balancer target group."
  value       = aws_lb_target_group.this.arn
}
