#!/bin/bash

# hong: 리팩토링 해놔서 아래 변수만 설정에 맞게  변경하셔서 쓰심 됨다

# 설정 변수
CONTAINER_NAME="spring-backend"  # 컨테이너 prefix
CONTAINER_SETUP_DELAY_SECOND=10  # 컨테이너 실행 지연 시간
MAX_RETRY_COUNT=15  # 서버 상태 확인 최대 시도 횟수
RETRY_DELAY_SECOND=2  # 서버 상태 확인 지연 시간(초)
BLUE_SERVER_URL="http://127.0.0.1:8081"  # blue 서버 URL
GREEN_SERVER_URL="http://127.0.0.1:8082"  # green 서버 URL
HEALTH_END_POINT="/api/health"  # 서버 health check 를 위한 엔드포인트 (200 응답만 오면 됩니당)
BLUE_DOCKER_COMPOSE_FILE_NAME="docker-compose.blue"  # blue 의 docker-compose 파일명 (ex. `docker-compose.blue.yml`)
GREEN_DOCKER_COMPOSE_FILE_NAME="docker-compose.green"  # green 의 docker-compose 파일명 (ex. `docker-compose.green.yml`)
NGINX_SERVICE_URL_FILE="/etc/nginx/conf.d/service-url.inc"  # NGINX 설정 파일 경로

# NGINX 재로드 함수
reload_nginx() {
    echo "NGINX 설정 변경 작업 시작"

    if nginx -t; then
        nginx -s reload
        echo "NGINX 설정 재로드 완료"
    else
        echo "NGINX 설정 오류 -> 롤백 수행"
        echo "set \$service_url $CURRENT_SERVICE_URL;" > $NGINX_SERVICE_URL_FILE
        nginx -s reload
        exit 1
    fi
}

# 헬스 체크 함수
health_check() {
    local REQUEST_URL=$1
    local RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRY_COUNT ]; do
        echo "상태 검사 ( $REQUEST_URL )  ...  $(( RETRY_COUNT + 1 ))"
        sleep $RETRY_DELAY_SECOND

        REQUEST=$(curl -o /dev/null -s -w "%{http_code}\n" $REQUEST_URL)
        if [ "$REQUEST" -eq 200 ]; then
            echo "상태 검사 성공"
            return 0
        fi

        RETRY_COUNT=$(( RETRY_COUNT + 1 ))
    done

    return 1
}

# 컨테이너 시작 함수
start_container() {
    local COLOR=$1
    local DOCKER_COMPOSE_FILE_NAME=$2
    local SERVER_URL=$3

    echo "$COLOR 컨테이너를 띄우는 중"
    docker-compose -p ${CONTAINER_NAME}-$COLOR -f ${DOCKER_COMPOSE_FILE_NAME}.yml up -d
    echo "${CONTAINER_SETUP_DELAY_SECOND}초 대기"
    sleep $CONTAINER_SETUP_DELAY_SECOND

    echo "$COLOR 서버 상태 확인 시작"
    if ! health_check "$SERVER_URL$HEALTH_END_POINT"; then
        echo "$COLOR 배포 실패"
        echo "$COLOR 컨테이너 정리"
        docker-compose -p ${CONTAINER_NAME}-$COLOR -f ${DOCKER_COMPOSE_FILE_NAME}.yml down
        exit 1
    else
        echo "$COLOR 배포 성공"
        echo "set \$service_url $SERVER_URL;" > $NGINX_SERVICE_URL_FILE
        reload_nginx
        echo "기존 ${OTHER_COLOR} 컨테이너 정리"
        docker-compose -p ${CONTAINER_NAME}-${OTHER_COLOR} -f ${OTHER_DOCKER_COMPOSE_FILE_NAME}.yml down
    fi
}

# 메인 스크립트 로직
if [ "$(docker ps -q -f name=${CONTAINER_NAME}-blue)" ]; then
    echo "blue >> green"
    OTHER_COLOR="blue"
    OTHER_DOCKER_COMPOSE_FILE_NAME=$BLUE_DOCKER_COMPOSE_FILE_NAME
    start_container "green" $GREEN_DOCKER_COMPOSE_FILE_NAME $GREEN_SERVER_URL
else
    echo "green >> blue"
    OTHER_COLOR="green"
    OTHER_DOCKER_COMPOSE_FILE_NAME=$GREEN_DOCKER_COMPOSE_FILE_NAME
    start_container "blue" $BLUE_DOCKER_COMPOSE_FILE_NAME $BLUE_SERVER_URL
fi
