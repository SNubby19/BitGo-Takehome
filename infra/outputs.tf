output "alb_public_url" {
  description = "The public DNS name of the Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}
