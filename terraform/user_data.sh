#!/bin/bash
set -e

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