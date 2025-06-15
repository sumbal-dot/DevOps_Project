resource "aws_lb_target_group" "web_app" {
  name     = "assignment-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}


resource "aws_lb_target_group" "metabase" {
  name        = "metabase-tg-sumbal"
  port        = 80       # Same ALB port (different internal target port)
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

lifecycle {
  prevent_destroy = false
}
health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200"
  }
}
