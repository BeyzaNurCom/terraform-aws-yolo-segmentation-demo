variable "project_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "user_data_path" {}
variable "github_repo_url" {}
