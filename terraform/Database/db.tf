resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}rds-subnet-group"
  subnet_ids = ["subnet-0066f13ca8756ccd6", "subnet-0025ad04a9f0860cf"]
}



resource "aws_db_instance" "rds_instance" {
  identifier             = "mizu-${var.environment}-db"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true
  username               = "admin"
  password               = "Password1234asd"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  backup_retention_period = 7
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
  tags = {
    Name = "mizu-${var.environment}-db-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "mizu-${var.environment}-db-sg"
  description = "Security group for RDS"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    vpc_id = "vpc-09f1e2d57a7d8edc0"
  tags = {
    Name = "mizu-${var.environment}-db-sg"
  }
}