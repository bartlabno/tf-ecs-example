data "aws_kms_key" "secretsmanager" {
  key_id = "alias/aws/secretsmanager"
}

resource "random_password" "db_username" {
  length  = 12
  special = false
}

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.environment}/${var.project}/db_password"
  description = "Database user credentials"
  kms_key_id  = data.aws_kms_key.secretsmanager.arn
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = <<EOF
{
"username": "${random_password.db_username.result}",
"password": "${random_password.db_password.result}"
}
EOF
}