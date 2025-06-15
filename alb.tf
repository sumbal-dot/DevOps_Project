# ALB with improved health checks and timeouts
resource "aws_lb" "web_app" {
  name               = "assignment-web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-06099f1fa27bdfebe", "subnet-08c64ce61a2597203"] # Public subnets
  idle_timeout       = 120 # Better for React apps

  enable_deletion_protection = false # Disable for testing (enable in prod)
  enable_http2               = true
  drop_invalid_header_fields = true  # Important for HTTPS

  tags = {
    Name = "Assignment-WebApp-ALB"
  }
}


# HTTP → HTTPS redirect (forced)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener with auto-validated cert
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  # Simplified default action (choose ONE of these options)

  # OPTION 1: Basic forwarding (recommended for most cases)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app.arn
  }
}

resource "aws_lb" "bi_alb" {
  name               = "bi-tool-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bi_sg.id]
  subnets            = ["subnet-025bbf60e1203440d", "subnet-08c64ce61a2597203"] # Your public subnets
}

# BI HTTPS listener (8443)
resource "aws_lb_listener_certificate" "bi_cert" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate_validation.bi_cert_validation.certificate_arn
}

# Listener rule for BI dashboard
resource "aws_lb_listener_rule" "bi_dashboard" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100  # Must be unique

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metabase.arn
  }

  condition {
    host_header {
      values = ["sumbal-bi.apparelcorner.shop"]
    }
  }
}

# Listener rule for BI dashboard
resource "aws_lb_listener_rule" "bi_dashboard_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10  # Must be unique

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metabase.arn
  }

  condition {
    host_header {
      values = ["sumbal-bi.apparelcorner.shop"]
    }
  }
}