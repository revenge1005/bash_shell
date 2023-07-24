#!/bin/bash

#> 패키지 리포지터리를 다운로드 받기 위한 명령어와 스크립트 개발을 위한 프로세스화

# reposync : 패키지 리포지터리 동기화 명령
# createrepo : 디렉터리의 리포지터리화하는 명령

#> 프로세스
# 1. 동기화를 할 리포지터리는 외부로부터 입력받아 변수에 저장
# 2. 리포지터리를 저장할 경로를 저장
# 3. 운영체제 버전을 확인
# 4. 리포지터리를 동기화
# 5. 동기화가 끝나면 리포지터리를 다운로드 받은 경로를 createrepo를 통해 리포지터리화

#> 참고
# https://itguava.tistory.com/103


# 리포지터리 목록을 입력받지 않고, 파일에 직접 입력해도 됨
repolist=$1
repopath=/var/www/html/repo/
osversion=$(cat /etc/redhat-release | awk '{print $(NF-1)}')

# 레파지토리 입력이 없으면 메시지를 보여주고 스크립트 종료
if [[ -z $1 ]]; then
  echo "Please input repository list. You can get repository from [yum repolist]"
  echo "Rhel7 Usage: reposync.sh \"rhel-7-server-rpms\""
  echo "Rhel8 Usage: reposync.sh \"rhel-8-for-x86_64-baseos-rpms\""
  exit;
fi

# 운영체제 버전에 따라 입력한 레포지토리만큼 동기화를 함.
for repo in $repolist; do
  # OS가 Rhel7일 경우
  # 가장 앞문자 하나를 추출하기 위해 ${변수:시작위치:길이}를 사용하여 OS 버전이 7인지 8인지를 확인
  if [ ${osversion:0:1} == 7 ]; then
    reposync --gpgcheck -l -n --repoid=$repo --download_path=$repopath
  # OS가 Rhel8일 경우
  elif [ ${osversion:0:1} == 8 ]; then
    reposync --download-metadata --repo=$repo -p $repopath
  fi
  # 해당 디렉토리를 레파지토리화한다.
  createrepo $repopath$repo
done
