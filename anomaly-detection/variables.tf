variable "monitor_name" {
  description = "Name of the AWS Cost Anomaly Monitor."
  type        = string
}

variable "subscription_name" {
  description = "Name of the AWS Cost Anomaly Subscription."
  type        = string
}

variable "notification_email" {
  description = "Email address that receives cost anomaly notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.notification_email))
    error_message = "notification_email must be a valid email address."
  }
}

variable "threshold_usd" {
  description = "Minimum anomaly impact in USD before a notification is sent."
  type        = number
  default     = 10

  validation {
    condition     = var.threshold_usd > 0
    error_message = "threshold_usd must be greater than zero."
  }
}
