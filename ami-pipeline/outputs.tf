# -----------------------------------------------------------------------------
# Image Builder Component
# -----------------------------------------------------------------------------

output "component_arn" {
  description = "ARN of the Golden AMI Image Builder component."
  value       = aws_imagebuilder_component.golden_ami.arn
}

# -----------------------------------------------------------------------------
# Image Recipe
# -----------------------------------------------------------------------------

output "image_recipe_arn" {
  description = "ARN of the Golden AMI image recipe."
  value       = aws_imagebuilder_image_recipe.golden_ami.arn
}

# -----------------------------------------------------------------------------
# Infrastructure Configuration
# -----------------------------------------------------------------------------

output "infrastructure_configuration_arn" {
  description = "ARN of the EC2 Image Builder infrastructure configuration."
  value       = aws_imagebuilder_infrastructure_configuration.golden_ami.arn
}

# -----------------------------------------------------------------------------
# Distribution Configuration
# -----------------------------------------------------------------------------

output "distribution_configuration_arn" {
  description = "ARN of the Golden AMI distribution configuration."
  value       = aws_imagebuilder_distribution_configuration.golden_ami.arn
}

# -----------------------------------------------------------------------------
# Image Pipeline
# -----------------------------------------------------------------------------

output "image_pipeline_arn" {
  description = "ARN of the Golden AMI Image Builder pipeline."
  value       = aws_imagebuilder_image_pipeline.golden_ami.arn
}

# -----------------------------------------------------------------------------
# Image Builder Instance Role
# -----------------------------------------------------------------------------

output "image_builder_role_arn" {
  description = "ARN of the IAM role used by EC2 Image Builder build instances."
  value       = aws_iam_role.image_builder.arn
}
