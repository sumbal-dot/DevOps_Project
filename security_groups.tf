# EC2 Security Group (now includes HTTP for ALB health checks)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow traffic from ALB to EC2"
  vpc_id      = var.vpc_id

  # ALB HTTPS access
  ingress {
    description     = "ALB_HTTPS_access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # ADDED: Allow HTTP for ALB health checks
  ingress {
    description     = "ALB_HTTP_health_checks"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow SSH for debugging (restrict IP in production)
  ingress {
    description = "SSH_access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Replace with your IP
  }

  egress {
    description = "All_outbound_traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Assignment-EC2-SecurityGroup"
  }
}

# ALB Security Group (unchanged but verified)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP_HTTPS_to_ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP_from_anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS_from_anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All_outbound_traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Assignment-ALB-SecurityGroup"
  }
}

# RDS Security Group
resource "aws_security_group" "db_sg" {
  name        = "assignment-db-sg"
  description = "Security group for RDS databases"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL_access_from_EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  ingress {
    description = "BI_Tool_HTTP_access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "PostgreSQL_access_from_EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "All_outbound_traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Assignment-DB-SecurityGroup"
  }
}


# BI Tool Security Group
resource "aws_security_group" "bi_sg" {
  name        = "assignment-bi-sg"
  description = "Security group for BI Tool"
  vpc_id      = var.vpc_id
  ingress {
    description = "BI_Tool_HTTP_access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "BI_Tool_HTTP_3000_Port_access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "BI_Tool_HTTPS_access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH_access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For testing only - restrict to your IP in production
  }

  egress {
    description = "All_outbound_traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Assignment-BI-SecurityGroup"
  }
}