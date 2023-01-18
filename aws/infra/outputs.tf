output "domain_name" {
  description = "Public domain name of EC2 instance"
  value       = aws_instance.web.public_dns
}
