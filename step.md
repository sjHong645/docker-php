## 최초 프로젝트 틀 만들기 

Dockerfile을 만들고 나서 

```
docker build -t docker_php:step1 .
```

명령어를 실행했다. 
- `-t` : 이미지의 이름과 태그를 설정하는 옵션 ⇒ 그래서 `<이미지이름>:<태그>`를 설정해줬다.
- `.` : Dockerfile의 위치 