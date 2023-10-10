resource "aws_launch_configuration" "ccp_course_practice_lc" {
  name            = "ccp-course-practice-lc"
  image_id        = var.default_ami
  instance_type   = "t2.micro"
  key_name        = "luit-keypair"
  user_data       = file("${path.module}/user-data.sh")
  security_groups = [aws_security_group.ccp_course_practice_sg.id]


  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ccp_course_practice_asg" {
  name                      = "ccp-course-practice-asg"
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 5
  vpc_zone_identifier       = [for s in aws_subnet.ccp_course_practice_subnets : s.id]
  launch_configuration      = aws_launch_configuration.ccp_course_practice_lc.name
  target_group_arns         = [aws_lb_target_group.ccp_course_practice_tg.arn]
  health_check_grace_period = 300
  health_check_type         = "ELB"

  tag {
    key                 = "name"
    value               = "ccp-practice-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "ccp_course_practice_website_lb" {
  name               = "ccp-course-practice-website-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ccp_course_practice_sg.id]
  subnets            = [for s in aws_subnet.ccp_course_practice_subnets : s.id]
  internal           = false
}

resource "aws_lb_target_group" "ccp_course_practice_tg" {
  name     = "ccp-course-practice-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ccp_course_practice_vpc.id
  health_check {
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "ccp_course_practice_listener" {
  load_balancer_arn = aws_lb.ccp_course_practice_website_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ccp_course_practice_tg.arn
  }
}

resource "aws_security_group" "ccp_course_practice_sg" {
  name        = "ccp-course-practice-sg"
  description = "security group to be used during the CCP course"
  vpc_id      = aws_vpc.ccp_course_practice_vpc.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ccp_course_practice_sg.id
}

resource "aws_security_group_rule" "inbound_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ccp_course_practice_sg.id
}

resource "aws_security_group_rule" "inbound_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ccp_course_practice_sg.id
}

resource "aws_security_group_rule" "outbound_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ccp_course_practice_sg.id
}

resource "aws_security_group_rule" "outbound_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ccp_course_practice_sg.id
}

