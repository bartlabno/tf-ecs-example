resource "aws_kms_key" "ecs_retention" {
  description             = "ecs_retention"
  deletion_window_in_days = 7
}

resource "aws_service_discovery_http_namespace" "react" {
  name = "${var.project}-${var.environment}"
}

resource "aws_cloudwatch_log_group" "react" {
  name = "/ecs/${var.environment}/${var.project}"
}

resource "aws_ecs_cluster" "react" {
  name = "${var.project}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.react.arn
  }

  tags = (tomap({
    "AWS.SSM.AppManager.ECS.Cluster.ARN" = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/react"
  }))
}