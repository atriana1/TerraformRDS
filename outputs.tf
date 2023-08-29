output "rds_endpoint" {
  value = aws_db_instance.arroyo_rds_mysql.endpoint
}

output "security_group_id" {
  value = aws_security_group.rds_sg.id
}