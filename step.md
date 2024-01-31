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