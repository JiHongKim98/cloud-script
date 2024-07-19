#!/bin/bash

# --- docker install ---

# ubuntu 패키지 업데이트
sudo apt-get update

# docker 설치에 필요한 패키지 설치
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# docker 공식 GPG키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# docker 의 안정적인 버전 저장소 추가
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# ubuntu 패키지 목록 업데이트
sudo apt-get update

# docker 패키지 설치
sudo apt-get install docker-ce docker-ce-cli containerd.io


# --- docker-compose install ---

# 최신 버전의 Docker Compose를 설치
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')

sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Docker Compose를 /usr/bin 경로에서도 사용할 수 있도록 심볼릭 링크 생성
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Docker Compose 버전 확인
docker-compose --version
