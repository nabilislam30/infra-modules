variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "Name of the CloudWatch Log Group used by CloudTrail."
  type        = string
}

variable "alarm_email_endpoint" {
  description = "Email address subscribed to SNS monitoring notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alarm_email_endpoint))
    error_message = "alarm_email_endpoint must be a valid email address."
  }
}

variable "metric_namespace" {
  description = "CloudWatch namespace used for security monitoring metrics."
  type        = string
  default     = "SecurityMonitoring"
}

variable "common_tags" {
  description = "Common tags applied to supported monitoring resources."
  type        = map(string)
  default     = {}
}
