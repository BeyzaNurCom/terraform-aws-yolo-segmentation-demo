output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "application_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}
