#!/bin/bash

# 128MB x 16 = 2GB swap 메모리
sudo dd if=/dev/zero of=/swapfile bs=128M count=16
# 읽기 및 쓰기 권한 부여
sudo chmod 600 /swapfile

# Linux 스왑 영역 설정
sudo mkswap /swapfile

# swap 메모리 활성화
sudo swapon /swapfile
sudo swapon -s

# 재부팅시에도 스왑 파일 적용
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
