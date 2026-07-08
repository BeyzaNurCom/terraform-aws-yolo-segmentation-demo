variable "project_name" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "alb_security_group_id" {}
variable "instance_ids" {
  type = list(string)
}
variable "app_port" {}
