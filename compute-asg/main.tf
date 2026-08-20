# -----------------------------------------------------------------------------
# IAM Trust Policy
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
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
# EC2 Instance Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "compute" {
  name               = "${var.name}-compute"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.compute.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "compute" {
  name = "${var.name}-compute"
  role = aws_iam_role.compute.name

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Secrets Manager Access
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "database_secret_access" {
  statement {
    sid    = "ReadDatabaseSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      var.database_secret_arn
    ]
  }

  statement {
    sid    = "DecryptDatabaseSecret"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      var.database_secret_kms_key_arn
    ]
  }
}

resource "aws_iam_role_policy" "database_secret_access" {
  name   = "${var.name}-database-secret-access"
  role   = aws_iam_role.compute.id
  policy = data.aws_iam_policy_document.database_secret_access.json
}

# -----------------------------------------------------------------------------
# Application Load Balancer Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "Security group for the Application Load Balancer."
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  description = "Allow inbound HTTPS traffic to the Application Load Balancer."

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"

  tags = var.common_tags
}

resource "aws_vpc_security_group_egress_rule" "alb_to_compute" {
  security_group_id = aws_security_group.alb.id

  description = "Allow the Application Load Balancer to reach compute instances."

  referenced_security_group_id = aws_security_group.compute.id
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Compute Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "compute" {
  name        = "${var.name}-compute"
  description = "Security group for Auto Scaling Group instances."
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "compute_from_alb" {
  security_group_id = aws_security_group.compute.id

  description = "Allow application traffic from the Application Load Balancer."

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.application_port
  to_port                      = var.application_port
  ip_protocol                  = "tcp"

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Dev SSH Learning Mode
# -----------------------------------------------------------------------------

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = aws_security_group.compute.id

  description = "Allow SSH from the configured development public IP."

  cidr_ipv4   = "${var.my_ip}/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Compute HTTPS Egress
# -----------------------------------------------------------------------------

# Compute instances require outbound HTTPS for AWS services and package access.
# Egress is restricted to TCP/443; no unrestricted protocol egress is permitted.
# trivy:ignore:AWS-0104
resource "aws_vpc_security_group_egress_rule" "compute_https" {
  security_group_id = aws_security_group.compute.id

  description = "Allow HTTPS egress for AWS service and package repository access."

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Compute PostgreSQL Egress
# -----------------------------------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "compute_to_database" {
  security_group_id = aws_security_group.compute.id

  description = "Allow PostgreSQL traffic from compute instances to the database."

  referenced_security_group_id = var.database_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

# The ALB is intentionally internet-facing while compute instances remain private.
# trivy:ignore:AWS-0053
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"

  drop_invalid_header_fields = true

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = var.public_subnet_ids

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Target Group
# -----------------------------------------------------------------------------

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    enabled  = true
    path     = var.health_check_path
    protocol = "HTTP"
  }

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Application Load Balancer Listener
# -----------------------------------------------------------------------------

# Development learning environment uses HTTP because no project domain or ACM
# certificate is available. The ALB is internet-facing, while compute instances
# remain behind the load balancer.
# trivy:ignore:AWS-0054
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.application_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# -----------------------------------------------------------------------------
# Launch Template
# -----------------------------------------------------------------------------

resource "aws_launch_template" "this" {
  name_prefix = "${var.name}-"

  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.enable_ssh ? var.key_name : null

  iam_instance_profile {
    name = aws_iam_instance_profile.compute.name
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address

    security_groups = [
      aws_security_group.compute.id
    ]
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = var.common_tags
  }

  tags = var.common_tags
}

# -----------------------------------------------------------------------------
# Auto Scaling Group
# -----------------------------------------------------------------------------

resource "aws_autoscaling_group" "this" {
  name = "${var.name}-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.compute_subnet_ids

  target_group_arns = [
    aws_lb_target_group.this.arn
  ]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-compute"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
