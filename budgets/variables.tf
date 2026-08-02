variable "budget_name" {
  description = "Name of the AWS Budget."
  type        = string
}

variable "monthly_limit" {
  description = "Monthly budget amount in USD."
  type        = number

  validation {
    condition     = var.monthly_limit > 0
    error_message = "monthly_limit must be greater than zero."
  }
}

variable "notification_email" {
  description = "Email address that receives budget alerts."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.notification_email))
    error_message = "notification_email must be a valid email address."
  }
}
