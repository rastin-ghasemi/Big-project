################
# Load Blancer #
################
resource "aws_security_group" "alb" {
    description = "Configure Access For the ALB"
    name = "${local.Prefix}-ALB-Access"
    vpc_id = aws_vpc.main.id
    ingress  {
        protocol = "tcp"
        from_port= 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress  {
        protocol = "tcp"
        from_port= 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        protocol = "tcp"
        from_port = 8000
        to_port = 8000
        security_groups = [aws_security_group.ecs_service.id]

    }
      # DENY all other outbound traffic (explicit deny - optional but recommended)
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Deny all other outbound traffic"
    
  }

}

resource "aws_lb" "api" {
    name="${local.Prefix}-lb"
    load_balancer_type = "application"
    subnets =[aws_subnet.public_subnets-a.id,aws_subnet.Private-b.id]
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "api" {
  name        = "${local.Prefix}-api-tg"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 8000
  
  # Health check configuration
  health_check {
    path                = "/api/health-check/"
  }

  # Important: Required for Fargate IP targets
/*
  What it does:

Creates the NEW target group first

Waits for it to be ready (passing health checks)

Updates resources (like ECS service or ALB listener) to use the NEW target group

Destroys the OLD target group
*/
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.Prefix}-api-tg"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}