# base image 
FROM php:8.0-fpm 

# apt-get을 최신버전으로 업데이트
# unzip, gpg, locales, wget, zlib1g-dev 패키지를 설치 
# docker-php-ext-install라는 도커 이미지에 필요한 외부 종속성 파일 설치 
RUN apt-get update && \
    apt-get install -y unzip gpg locales wget zlib1g-dev && \
    docker-php-ext-install pdo_mysql mysqli

# 온라인에 있는 파일 다운로드 
RUN cur -sS https://getcomposer.org/installer|php && \
    mv composer.phar/usr/local/bin/composer 

