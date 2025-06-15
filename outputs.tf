output "alb_dns_name" {
  value       = aws_lb.web_app.dns_name
  description = "Application Load Balancer DNS"
}

output "rds_mysql_endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "MySQL RDS Endpoint"
}

output "rds_postgres_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "PostgreSQL RDS Endpoint"
}

output "target_group_arn" {
  description = "The ARN of the ALB target group"
  value       = aws_lb_target_group.web_app.arn
}

output "ssl_cert_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.ssl_cert.arn
}
