data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution.arn
}

resource "aws_iam_role_policy" "password_policy_secretsmanager" {
  name = "password-policy-secretsmanager"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_secretsmanager_secret.db_password.arn}"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecs_task_definition" "backend" {
  family = "${var.project}-${var.environment}-backend"

  cpu    = 1
  memory = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "${var.project}-${var.environment}-backend"
      image     = "istrald/react-backend:${var.backend_version}"
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
          name          = "${var.project}-${var.environment}-backend"
          containerPort = 3001
          hostPort      = 3001
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
          name  = "ENDPOINT"
          value = aws_docdb_cluster.react.endpoint
        }
      ]
      secrets = [
        {
          name      = "USER"
          valueFrom = "${aws_secretsmanager_secret.db_password.arn}:username::"
        },
        {
          name      = "PASS"
          valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
        }
      ]
    }
  ])
}