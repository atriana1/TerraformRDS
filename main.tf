# *****************
# VPC Configuration
# *****************
resource "aws_vpc" "arroyo_rds_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "arroyo_igw" {
  vpc_id = aws_vpc.arroyo_rds_vpc.id
}

# *********************
# SUBNETS Configuration
# *********************
resource "aws_subnet" "rds_subnet_1" {
  vpc_id     = aws_vpc.arroyo_rds_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "rds_subnet_2" {
  vpc_id     = aws_vpc.arroyo_rds_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]
}

# *************************
# RouteTables Configuration
# *************************
resource "aws_route_table" "arroyo_route_table" {
  vpc_id = aws_vpc.arroyo_rds_vpc.id
}

resource "aws_route" "arroyo_route" {
  route_table_id         = aws_route_table.arroyo_route_table.id
  destination_cidr_block = "0.0.0.0/0"  # Ruta por defecto para todo el tráfico
  gateway_id             = aws_internet_gateway.arroyo_igw.id
}

resource "aws_route_table_association" "arroyo_subnet_association1" {
  subnet_id      = aws_subnet.rds_subnet_1.id
  route_table_id = aws_route_table.arroyo_route_table.id
}

resource "aws_route_table_association" "arroyo_subnet_association2" {
  subnet_id      = aws_subnet.rds_subnet_2.id
  route_table_id = aws_route_table.arroyo_route_table.id
}

# ***************************
# SecurityGroup Configuration
# ***************************

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ***********************
# RDS MySql Configuration
# ***********************

resource "aws_db_instance" "arroyo_rds_mysql" {
  engine              = "mysql"
  identifier          = "arroyomysql"
  allocated_storage   = 20
  storage_type        = "gp2"  
  engine_version      = "8.0.33"
  instance_class      = "db.t2.micro"
  username            = "admin"
  password            = "Colombia2023."
  parameter_group_name = "default.mysql8.0"  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
  publicly_accessible = true
  

  db_subnet_group_name   = aws_db_subnet_group.rds_db_subnet_group.name
  
  depends_on = [aws_security_group.rds_sg]

  tags = {
    Name = "arroyoDb"
  }
}
