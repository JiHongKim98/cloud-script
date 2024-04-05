#!/bin/bash

# package and cache update
sudo yum update -y

# install docker
## Amazon Linux 2023 version
sudo yum install -y docker

## Amazon Linux 2 version
# sudo amazon-linux-extras install docker

# Docker 서비스 시작
sudo service docker start

# 부팅 시 자동으로 Docker 서비스 시작
sudo chkconfig docker on

# etc
docker ps
