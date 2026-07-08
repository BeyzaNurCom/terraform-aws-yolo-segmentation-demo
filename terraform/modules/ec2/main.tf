resource "aws_instance" "app" {
  count                  = length(var.subnet_ids)
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = [var.security_group_id]

  user_data = templatefile(var.user_data_path, {
    github_repo_url = var.github_repo_url
  })

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-ec2-${count.index == 0 ? "1a" : "1b"}"
  }
}
