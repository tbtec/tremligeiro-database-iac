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

resource "aws_db_instance" "postgres_db" {
  identifier          = "tremligeiro-postgres-db"
  engine              = "postgres"
  instance_class      = "db.t3.micro"  
  allocated_storage   = 10  
  storage_type        = "gp2" 
  db_name             = "tremligeiro_db"  
  username            = "admintremligeiro" 
  password            = "admintremligeiro" 
  skip_final_snapshot = true  

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  backup_retention_period = 1 
  publicly_accessible     = false  

  tags = {
    Name = "PostgresDB"
  }

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  multi_az             = false

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
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.name_subnet_a.cidr_block, data.aws_subnet.name_subnet_b.cidr_block]  
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
