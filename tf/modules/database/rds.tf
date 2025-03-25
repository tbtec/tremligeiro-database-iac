provider "aws" {
  region = "us-east-1"  
}

data "aws_vpc" "name_vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-tremligeiro"]
  }
}

data "aws_subnet" "name_subnet_a" {
  filter {
    name   = "tag:Name"
    values = ["vpc-tremligeiro-private-us-east-1a"]
  }
}

data "aws_subnet" "name_subnet_b" {
  filter {
    name   = "tag:Name"
    values = ["vpc-tremligeiro-private-us-east-1b"]
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "db-pg-tremligeiro-postgres-db"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # Disable SSL
  }
}

resource "aws_db_instance" "postgres_db" {
  identifier              = "tremligeiro-postgres-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"  
  allocated_storage       = 10  
  storage_type            = "gp2" 
  db_name                 = "tremligeiro_db"  
  username                = "admintremligeiro" 
  password                = "admintremligeiro" 
  skip_final_snapshot     = true  
  backup_retention_period = 1 
  publicly_accessible     = false  
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name


  tags = {
    Name = "PostgresDB"
  }

  depends_on = [aws_security_group.rds_security_group]
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Secury Group for RDS"
  vpc_id      = data.aws_vpc.name_vpc.id
  ingress {
    description = "Allow all traffic from within the security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow all traffic from the VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.name_vpc.cidr_block]  
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db-subnet-group"
  subnet_ids  = [
    data.aws_subnet.name_subnet_a.id, 
    data.aws_subnet.name_subnet_b.id
  ]

  tags = {
    Name = "DB Subnet Group"
  }

}
