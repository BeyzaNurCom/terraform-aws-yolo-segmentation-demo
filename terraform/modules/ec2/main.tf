resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = templatefile(var.user_data_path, {
    github_repo_url = var.github_repo_url
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
