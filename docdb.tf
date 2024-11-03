resource "aws_docdb_subnet_group" "react" {
  name       = "${var.project}-${var.environment}-db-subnet"
  subnet_ids = module.vpc-react.database_subnets
}

resource "aws_docdb_cluster" "react" {
  cluster_identifier = "${var.project}-${var.environment}"
  engine             = "docdb"

  master_username = random_password.db_username.result
  master_password = random_password.db_password.result

  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true

  db_subnet_group_name = aws_docdb_subnet_group.react.name

  deletion_protection = true
}

resource "aws_docdb_cluster_instance" "react" {
  count              = var.environment != "prod" ? 1 : 2
  identifier         = "${var.project}-${count.index}"
  cluster_identifier = aws_docdb_cluster.react.id
  engine             = aws_docdb_cluster.react.engine
  instance_class     = var.environment != "prod" ? "db.t3.medium" : "db.r6g.large"
}