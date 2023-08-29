resource "aws_vpc" "arroyo_rds_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "arroyo_igw" {
  vpc_id = aws_vpc.arroyo_rds_vpc.id
}

resource "aws_subnet" "rds_subnet_1" {
  vpc_id     = aws_vpc.arroyo_rds_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "rds_subnet_2" {
  vpc_id     = aws_vpc.arroyo_rds_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.arroyo_rds_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Access from any IP
  }
}

resource "aws_db_instance" "arroyo_rds_mysql" {
  allocated_storage    = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t2.micro"
  db_name             = "arroyoDb"
  username            = "admin"
  password            = "Colombia2023."
  skip_final_snapshot = true
  
  
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
  depends_on = [aws_internet_gateway.arroyo_igw]

  tags = {
    Name = "arroyoDb"
  }
}
