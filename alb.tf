# alb
resource "aws_alb" "alb" {
  name            = "alb"
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.load_balancer.id}"]
  subnets = aws_subnet.public.*.id

  tags = merge(
    { "Name" = "${var.main_project_tag}-alb" },
    { "Project" = var.main_project_tag }
  )
}

# target group
resource "aws_alb_target_group" "group" {
  name_prefix          = "csul-"
  port                 = 8500
  protocol             = "HTTP"
  vpc_id               = aws_vpc.consul-vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.consul.io/api-docs/health
  health_check {
    enabled             = true
    interval            = 10
    path                = "/health" // the consul API health port?
    protocol            = "HTTP"              // switch to HTTPS?
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
    port                = 80
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg" },
    { "Project" = var.main_project_tag }
  )
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}

## Application Load Balancer - Consul Web Client
resource "aws_lb" "alb_web" {
  name_prefix        = "csulw-" # 6 character length
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public.*.id
  idle_timeout       = 60

  tags = merge(
    { "Name" = "${var.main_project_tag}-alb-web" },
    { "Project" = var.main_project_tag }
  )
}

## Target Group
resource "aws_lb_target_group" "alb_targets_web" {
  name_prefix          = "csulw-"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.consul-vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  # https://www.consul.io/api-docs/health
  health_check {
    enabled             = true
    interval            = 10
    path                = "/index.html" // the consul API health port?
    protocol            = "HTTP"    // switch to HTTPS?
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
    port                = 80
  }

  tags = merge(
    { "Name" = "${var.main_project_tag}-tg-web" },
    { "Project" = var.main_project_tag }
  )
}

## Default HTTP listener
resource "aws_lb_listener" "alb_http_web" {
  load_balancer_arn = aws_lb.alb_web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_targets_web.arn
  }
}