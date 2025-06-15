resource "aws_launch_template" "web_app" {
  name_prefix   = "react-app-lt-"
  image_id      = "ami-0fe972392d04329e1" # Amazon Linux 2 AMI 
  instance_type = "t3.micro" 
  key_name      = var.key_name

  user_data = base64encode(file("al2_userdata.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.ec2_sg.id]
  }

}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-06099f1fa27bdfebe", "subnet-08c64ce61a2597203"]
  launch_template {
    id      = aws_launch_template.web_app.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.web_app.arn]
}

# BI Instance (Redash/Metabase) - Single EC2 
resource "aws_instance" "bi_tool" {
  ami           = "ami-0d1b5a8c13042c939" # Ubuntu
  instance_type = "t3.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.bi_sg.id]
  subnet_id     = "subnet-025bbf60e1203440d"
  
  user_data = filebase64("${path.module}/bi_userdata.sh")

    root_block_device {
    volume_size = 8
    volume_type = "gp3"
  tags = {
    Name = "BI-Tool-Instance"
  }
}
}

resource "aws_launch_template" "bi_dash" {
  name_prefix   = "ubuntu-bi-"
  image_id      = "ami-0d1b5a8c13042c939"
  instance_type = "t3.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.bi_sg.id]

  user_data = filebase64("${path.module}/bi_userdata.sh")

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "autoscaling-ubuntu"
    }
  }
}

resource "aws_autoscaling_group" "bi_asg" {
  name                      = "bi-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"                # Using ALB health checks
  health_check_grace_period = 900               # 5 mins grace
  launch_template {
    id      = aws_launch_template.bi_dash.id
    version = "$Latest"
  }
  vpc_zone_identifier       = ["subnet-06099f1fa27bdfebe", "subnet-08c64ce61a2597203"]

  target_group_arns         = [aws_lb_target_group.metabase.arn]

  tag {
    key                 = "Name"
    value               = "bi-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
