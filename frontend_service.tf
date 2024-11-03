resource "aws_ecs_service" "frontend" {
  name            = "${var.project}-${var.environment}-frontend"
  cluster         = aws_ecs_cluster.react.id
  task_definition = "${aws_ecs_task_definition.frontend.id}:${aws_ecs_task_definition.frontend.revision}"
  desired_count   = 2
  launch_type     = "FARGATE"

  depends_on = [aws_cloudwatch_log_group.react]

  enable_ecs_managed_tags = true

  health_check_grace_period_seconds = 120
  propagate_tags                    = "TASK_DEFINITION"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  wait_for_steady_state = true

  load_balancer {
    container_name   = "${var.project}-${var.environment}-frontend"
    container_port   = "3001"
    target_group_arn = aws_lb_target_group.tg_frontend.arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.allow_internal.id,
      aws_security_group.allow_https.id
    ]
    subnets = module.vpc-react.private_subnets
  }
}