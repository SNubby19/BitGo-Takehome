resource "aws_security_group" "alb" {
  name        = "alb_security_group"
  description = "Allow HTTPS traffic from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing the ALB to forward requests to your containers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


variable "ephemeral_port_min" {
  description = "The lowest port in the ephemeral range"
  type        = number
  default     = 32768
}

variable "ephemeral_port_max" {
  description = "The highest port in the ephemeral range"
  type        = number
  default     = 65535
}

resource "aws_security_group" "ecs" {
  name = "compute_security_groups"
  description = "Allow traffic only from the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.ephemeral_port_min
    to_port     = var.ephemeral_port_max
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
