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

COPY ./example-app .
RUN composer install

# 커맨드 명령어를 배열의 형식으로 입력했다. 
# 즉, 이미지 내에서 php artisan server --host 0.0.0.0이라는 커맨드가 실행된다. 
CMD ["php", "artisan", "serve", "--host", "0.0.0.0"]

