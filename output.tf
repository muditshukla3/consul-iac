output "alb-url" {
    value = aws_alb.alb.dns_name
}

output "alb-web-url" {
    value = aws_lb.alb_web.dns_name
}