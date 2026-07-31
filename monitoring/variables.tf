variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "CloudWatch Log Group used by CloudTrail."
  type        = string
}

variable "alarm_email_endpoint" {
  description = "Email address subscribed to SNS alarm notifications."
  type        = string
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)

  default = {}
}

variable "metric_namespace" {
  description = "CloudWatch namespace used for security monitoring metrics."
  type        = string
  default     = "SecurityMonitoring"
}

variable "deployment_role_arns" {
  description = "IAM role ARNs authorised to make infrastructure changes through Terraform."
  type        = set(string)

  validation {
    condition     = length(var.deployment_role_arns) > 0
    error_message = "At least one approved deployment role ARN must be provided."
  }
}
