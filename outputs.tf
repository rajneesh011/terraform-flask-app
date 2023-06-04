output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "instance_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "user_data" {
  value = aws_instance.ubuntu.user_data
}
