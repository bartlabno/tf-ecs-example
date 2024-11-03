resource "aws_ecs_task_definition" "frontend" {
  family = "${var.project}-${var.environment}-frontend"

  cpu    = 1
  memory = 512

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "${var.project}-${var.environment}-frontend"
      image     = "istrald/react:${var.frontend_version}"
      essential = true

      memory         = 512
      cpu            = 1
      mountPoints    = []
      systemControls = []
      volumesFrom    = []

      logConfiguration = {
        Logdriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.environment}/${var.project}"
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      portMappings = [
        {
          name          = "${var.project}-${var.environment}-frontend"
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "REACT_APP_API_URL"
          value = "${aws_alb.alb_backend.dns_name}:3001"
        }
      ]
    }
  ])
}