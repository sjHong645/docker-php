# base image 
FROM php:8.0-fpm 

# apt-get을 최신버전으로 업데이트
# unzip, gpg, locales, wget, zlib1g-dev 패키지를 설치 
# docker-php-ext-install라는 도커 이미지에 필요한 외부 종속성 파일 설치 
RUN apt-get update && \
    apt-get install -y unzip gpg locales wget zlib1g-dev && \
    docker-php-ext-install pdo_mysql mysqli

# 온라인에 있는 파일 다운로드 
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer 

# WORKDIR를 통해 RUN, CMD, ENTRYPOINT에서 설정한 커맨드가 실행될 디렉토리를 설정함 
# 즉, 여기서는 /app/src에서 커맨드들이 실행된다. 
WORKDIR /app/src 

# 1단계 Dockerfile의 COPY, CMD 커맨드 편집
# 이 과정을 통해 composer install의 결과를 이미지에 별도로 캐시할 수 있다. 
# composer.json, composer.lock 파일만 먼저 복사해서 라이브러리 설치를 함으로써 
# 라이브러리의 조건이 바뀌지 않는 한 이미지 캐시를 계속 사용할 수 있는 상태가 된다. 
COPY ./example-app/compose.* ./
RUN mkdir -p ./database/seeds && mkdir -p ./database/factories && composer install

# 전체 디렉토리를 복사했다. 
COPY ./example-app .

# 실행하던 커맨드를 shell 스크립트 파일을 실행하도록 변경 
CMD ["/app/src/entrypoint.sh"]

