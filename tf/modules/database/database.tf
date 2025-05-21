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

### PostgreSQL (RDS)
resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "db-pg-tremligeiro-postgres-db"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # Disable SSL
  }
}

resource "aws_db_instance" "postgres_db_order" {
  identifier              = "tremligeiro-postgres-db-order"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"  
  allocated_storage       = 10  
  storage_type            = "gp2" 
  db_name                 = "tremligeiro_order_db"  
  username                = "admintremligeiro" 
  password                = "admintremligeiro" 
  skip_final_snapshot     = true  
  backup_retention_period = 1 
  publicly_accessible     = false  
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name

  tags = {
    Name = "PostgresDB"
  }

  depends_on = [aws_security_group.rds_security_group]
}

resource "aws_db_instance" "postgres_db_payment" {
  identifier              = "tremligeiro-postgres-db-payment"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"  
  allocated_storage       = 10  
  storage_type            = "gp2" 
  db_name                 = "tremligeiro_payment_db"  
  username                = "admintremligeiro" 
  password                = "admintremligeiro" 
  skip_final_snapshot     = true  
  backup_retention_period = 1 
  publicly_accessible     = false  
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name

  tags = {
    Name = "PostgresDB"
  }

  depends_on = [aws_security_group.rds_security_group]
}

resource "aws_db_instance" "postgres_db_production" {
  identifier              = "tremligeiro-postgres-db-production"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"  
  allocated_storage       = 10  
  storage_type            = "gp2" 
  db_name                 = "tremligeiro_production_db"  
  username                = "admintremligeiro" 
  password                = "admintremligeiro" 
  skip_final_snapshot     = true  
  backup_retention_period = 1 
  publicly_accessible     = false  
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name

  tags = {
    Name = "PostgresDB"
  }

  depends_on = [aws_security_group.rds_security_group]
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security Group for RDS"
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

### MongoDB (Amazon DocumentDB)
resource "aws_docdb_cluster_parameter_group" "docdb_parameter_group" {
  family = "docdb5.0"
  name   = "docdb-pg-tremligeiro-mongo-db"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
resource "aws_security_group" "docdb_security_group" {
  name        = "docdb-security-group"
  description = "Security Group for DocumentDB"
  vpc_id      = data.aws_vpc.name_vpc.id

  ingress {
    description = "Allow all traffic from within the security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow MongoDB traffic"
    from_port   = 27017
    to_port     = 27017
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

resource "aws_db_subnet_group" "docdb_subnet_group" {
  name        = "docdb-subnet-group"
  subnet_ids  = [
    data.aws_subnet.name_subnet_a.id, 
    data.aws_subnet.name_subnet_b.id
  ]

  tags = {
    Name = "MongoDB Subnet Group"
  }
}

resource "aws_docdb_cluster" "mongo_cluster_customer" {
  cluster_identifier     = "tremligeiro-customer-db"
  engine                 = "docdb"
  master_username        = "admintremligeiro"
  master_password        = "admintremligeiro"
  db_subnet_group_name   = aws_db_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_security_group.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_parameter_group.name
  port = 27017

  tags = {
    Name = "MongoDBCluster"
  }

  skip_final_snapshot = true
}

resource "aws_docdb_cluster" "mongo_cluster_product" {
  cluster_identifier     = "tremligeiro-product-db"
  engine                 = "docdb"
  master_username        = "admintremligeiro"
  master_password        = "admintremligeiro"
  db_subnet_group_name   = aws_db_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_security_group.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_parameter_group.name
  port = 27017

  tags = {
    Name = "MongoDBCluster"
  }

  skip_final_snapshot = true
}



