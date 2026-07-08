#!/bin/bash 
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

# Create 4GB Swap Space to prevent Out-Of-Memory (OOM) on t3.micro
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

dnf update -y
dnf install -y docker git

systemctl enable docker
systemctl start docker

cd /home/ec2-user

git clone ${github_repo_url} app-repo 
cd app-repo/app

mkdir -p models static/uploads

docker build -t yolo-segmentation-app .

docker run -d \
  --name yolo-segmentation-app \
  --restart unless-stopped \
  -p 5000:5000 \
  yolo-segmentation-app 