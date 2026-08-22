# -----------------------------------------------------------------------------
# IAM Trust Policy
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "image_builder_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

# -----------------------------------------------------------------------------
# EC2 Image Builder Instance Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "image_builder" {
  name               = "${var.name}-image-builder"
  assume_role_policy = data.aws_iam_policy_document.image_builder_assume_role.json

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Required Image Builder Permissions
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "image_builder" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.image_builder.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -----------------------------------------------------------------------------
# EC2 Image Builder Instance Profile
# -----------------------------------------------------------------------------

resource "aws_iam_instance_profile" "image_builder" {
  name = "${var.name}-image-builder"
  role = aws_iam_role.image_builder.name

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Golden AMI Build Component
# -----------------------------------------------------------------------------

resource "aws_imagebuilder_component" "golden_ami" {
  name     = "${var.name}-golden-ami"
  platform = "Linux"
  version  = var.component_version

  description = "Build and hardening component for the Golden AMI."

  data = var.component_document

  tags = var.common_tags

  # Image Builder components are immutable and versioned.
  # Document changes must be accompanied by a component_version bump.
  # This prevents API/provider formatting normalisation from causing
  # unnecessary replacement of an unchanged component.
  lifecycle {
    ignore_changes = [
      data
    ]
  }
}

# -----------------------------------------------------------------------------
# Golden AMI Image Recipe
# -----------------------------------------------------------------------------

resource "aws_imagebuilder_image_recipe" "golden_ami" {
  name         = "${var.name}-golden-ami"
  version      = var.recipe_version
  parent_image = var.parent_image

  component {
    component_arn = aws_imagebuilder_component.golden_ami.arn
  }

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# EC2 Image Builder Infrastructure Configuration
# -----------------------------------------------------------------------------

resource "aws_imagebuilder_infrastructure_configuration" "golden_ami" {
  name                  = "${var.name}-golden-ami"
  instance_profile_name = aws_iam_instance_profile.image_builder.name

  instance_types = [
    var.instance_type
  ]

  subnet_id          = var.subnet_id
  security_group_ids = var.security_group_ids

  instance_metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  terminate_instance_on_failure = true

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Golden AMI Distribution Configuration
# -----------------------------------------------------------------------------

resource "aws_imagebuilder_distribution_configuration" "golden_ami" {
  name = "${var.name}-golden-ami"

  distribution {
    region = var.distribution_region

    ami_distribution_configuration {
      name = "${var.name}-golden-ami-{{ imagebuilder:buildDate }}"

      ami_tags = var.common_tags
    }
  }

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Golden AMI Image Pipeline
# -----------------------------------------------------------------------------

resource "aws_imagebuilder_image_pipeline" "golden_ami" {
  name = "${var.name}-golden-ami"

  image_recipe_arn                 = aws_imagebuilder_image_recipe.golden_ami.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.golden_ami.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.golden_ami.arn

  image_tests_configuration {
    image_tests_enabled = true
  }

  tags = var.common_tags

  lifecycle {
    replace_triggered_by = [
      aws_imagebuilder_image_recipe.golden_ami
    ]
  }
}
