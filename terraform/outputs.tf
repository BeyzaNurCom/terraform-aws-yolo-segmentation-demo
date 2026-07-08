output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "application_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "ec2_private_ips" {
  value = module.ec2.private_ips
}
