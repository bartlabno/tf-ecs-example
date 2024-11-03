resource "aws_alb" "alb_backend" {
  name               = "${var.project}-${var.environment}-backend"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc-react.public_subnets
  security_groups = [
    aws_security_group.allow_internal.id,
    aws_security_group.allow_https.id
  ]
}

resource "aws_lb_target_group" "tg_backend" {
  name        = "${var.project}-${var.environment}-backend"
  port        = 3001
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

resource "aws_lb_listener" "listener_backend" {
  load_balancer_arn = aws_alb.alb_backend.id
  port              = "3001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_backend.id
  }
}