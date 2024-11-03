data "aws_acm_certificate" "react" {
  domain   = var.base_domain
  statuses = ["ISSUED"]
}

resource "aws_alb" "alb_frontend" {
  name               = "${var.project}-${var.environment}-frontend"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc-react.public_subnets
  security_groups = [
    aws_security_group.allow_internal.id,
    aws_security_group.allow_https.id
  ]
}

resource "aws_lb_target_group" "tg_frontend" {
  name        = "${var.project}-${var.environment}-frontend"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc-react.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

}

resource "aws_lb_listener" "listener_frontend" {
  load_balancer_arn = aws_alb.alb_frontend.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "listener_https_frontend" {
  load_balancer_arn = aws_alb.alb_frontend.id
  port              = "80"
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.react.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_frontend.id
  }
}