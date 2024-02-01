## 최초 프로젝트 틀 만들기 

Dockerfile을 만들고 나서 

```
docker build -t docker_php:step1 .
```

명령어를 실행했다. 
- `-t` : 이미지의 이름과 태그를 설정하는 옵션 ⇒ 그래서 `<이미지이름>:<태그>`를 설정해줬다.
- `.` : Dockerfile의 위치 

이미지로 컨테이너를 생성해서 곧바로 bash에서 확인 (백그라운드에서 동작하는게 아니라서 bash 창을 나가면 컨테이너도 종료됨)
```
docker run --name step1 -it docker_php:step1 bash 
```

해당 bash 창에서 다음 내용 입력 
```
# 컨테이너 내부에 example-app이라는 디렉토리를 생성 
# 해당 디렉토리 안에 Laravel 프로젝트 파일이 생성된다. 
composer create-project laravel/laravel example-app --prefer-dis 
```

step1이라는 docker 컨테이너의 /var/www/html/example-app를 복사하려고 한다. 
```
docker cp step1:/var/www/html/example-app .
```

## 프로젝트 틀을 이용해서 실행 환경 이미지 만들기 

이번에는 Laravel이 실제로 움직이는 실행 환경의 이미지를 만든다. 

이미지를 만들고 나면 아래의 명령어를 실행해서 브라우저에 접속할 수 있다.

```
# host의 포트번호 8000을 컨테이너 내부 포트번호 8000과 연결했다. 

docker run -it --name step2 -p 8000:8000 docker_php:step2
```

이걸 실행하고 나면 `http://localhost:8000` 또는 `http://0.0.0.0:8000` 주소로 Laravel 프로젝트를 볼 수 있다. 

## 효율적인 build를 위한 설정 

Docker는 이미지를 빌드할 때 Dockerfile 내부에 적혀있는 커맨드의 결과를 캐시한다 ⇒ 때문에 동일한 커맨드가 있다면 캐시를 사용해서 빠르게 처리한다. 

하지만... 같은 커맨드임에도 `결과에 차이`가 발생한다면 그 위치부터 build를 새로 시작한다.  
ex) `COPY ./example-app .` : 명령어 자체는 변함이 없어도 해당 프로젝트 내에 새로운 페이지 추가 or 코드 수정을 했다면

이미지의 결과에 차이가 발생하니까 그 이후의 커맨드들 까지 새롭게 실행된다. ⇒ 시간이 굉장히 늦어진다. 

도커의 `Layer`의 개념을 생각하면 된다. 변경된 이후의 명령어부터 새롭게 Layer를 만들어야 하기 때문에  
이전에 설치했던 layer들을 최대한 활용할 수 있도록 하기 위해 명령어들의 순서를 잘 고려해야 한다. 

이번 실습에서는 3단계를 거친다. 
1. Dockerfile의 COPY, CMD 커맨드 편집
2. composer가 install 이후 자동으로 실행되는 커맨드를 컨테이너가 동작할 때 실행되도록 변경
3. composer가 install 이후 실행되어야 하는 커맨드를 스크립트 파일에 저장 

### 2단계. composer.json에서 `scripts` 부분을 삭제했다. 

- example-app/composer.json 파일
```
# 해당 부분은 composer install 때 실행되는 커맨드 
# post-autoload-dump와 post-update-cmd는 처음에만 실행하면 돼서 
# RUN mkdir -p ./database/seeds && mkdir -p ./database/factories를 추가했다. 
"scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
```

### 3단계. composer가 install 이후 실행되어야 하는 커맨드를 스크립트 파일에 저장 

이를 위해 example-app 디렉터리에 entrypoint.sh 파일을 만들고 파일 권한을 755로 맞춘다. 

- entrypoint.sh에 들어갈 내용
```
# 앞서 composer.json에서 삭제한 post-autoload-dump 작업 
php aritisan package:discover --ansi 

php aritisan serve --host 0.0.0.0
```

cf) 2,3단계에서 수정 및 추가할 파일들은 모두 컨테이너로 부터 로컬에 복사한 파일들을 얘기한다. 

이렇게 모든 설정을 마치고 이미지를 빌드하고 다시 한 번 똑같이 빌드하면 cache가 적용된 걸 확인할 수 있다. 

## 로컬 개발 환경 
지금까지 만든 환경에서 개발을 진행한다.  
여기서 `docker-compose`를 사용해서 로컬 개발환경을 만들기 위해 `docker-compose.yml`을 만들어야 한다. 

``` yml
version: '3'

services: 
  laravel: # laravael이라는 이름의 컨테이너 
    image: docker_php:step4 # 이미지는 docker_php:step4 사용 
    build: . # 이미지가 없으면 .(현재 디렉토리)를 기준으로 docker build를 수행해서 이미지를 만들고 이후의 동작 시작 
    ports:
      - "8000:8000" # host의 8000번 포트와 container의 8000번 포트를 연결
    volumes:
      - ./example-app:/app/src # 로컬 폴더와 컨테이너 폴더 마운트
      - /app/src/vendor # 해당 디렉토리는 컨테이너에 있는 걸 사용
```

이후에 `docker-compose up` 커맨드를 사용한다. `docker_php:step4` 이미지가 없어서 build부터 시작한다. 
build가 끝나면 컨테이너가 시작되고 이미지도 빌드되어 있는 걸 확인할 수 있다. 

## 인증 도입 

준비된 개발 환경에 간단한 `인증 기능`을 적용해보자. Laravel은 기본적으로 Breeze, Jetstream 두 가지 옵션을 제공한다.  
여기서는 간단한 인증 기능을 갖는 Breeze를 사용하겠다. 

1) 우선 `docker-compose.yml` 파일 편집 ⇒ 오타가 있어서 여기서 중단
