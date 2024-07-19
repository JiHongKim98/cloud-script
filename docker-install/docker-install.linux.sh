#!/bin/bash

# --- docker install ---

# 패키지 및 캐시 업데이트
sudo yum update -y

# docker 설치
## 아마존 리눅스 2023 버전
sudo yum install -y docker
## 아마존 리눅스 2 버전
# sudo amazon-linux-extras install docker

# docker 서비스 시작
sudo service docker start

# 부팅 시 자동으로 docker 서비스 시작
sudo chkconfig docker on

# docker 버전 확인
docker --version


# --- docker-compose install ---

# 최신 버전의 Docker Compose를 설치
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')

sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Docker Compose를 /usr/bin 경로에서도 사용할 수 있도록 심볼릭 링크 생성
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# docker-compose 버전 확인
docker-compose --version
