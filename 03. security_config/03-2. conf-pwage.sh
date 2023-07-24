#!/bin/bash

#> 패스워드 변경 주기 설정
# 패스워드 변경 주기 설정은 chage라는 명령어에 의해 설정할 수 있다.

#> 필요한 정보
# 패스워드 변경 주기 설정 명령어 : chage
# chage 옵션 및 의미
#   ㆍ-d, --lastday LAST_DAY        : 마지막으로 패스워드를 변경한 날짜 설정
#   ㆍ-E, --expiredate EXPIRE_DATE  : 특정 계정의 패스워드 만료일 설정
#   ㆍ-l, --list                    : 패스워드 설정 주기 정보 확인
#   ㆍ-m, --mindays MIN_DAYS        : 패스워드 변경 최소 설정일
#   ㆍ-M, --maxdays MAX_DAYS        : 패스워드 변경 최대 설정일
#   ㆍ-W, --warndays WARN_DAYS      : 패스워드 만료 경고일

#> 프로세스
# 1. 패스워드 설정 주기를 설정할 서버 정보를 변수에 저장한다.
# 2. 패스워드 설정 주기를 설정할 사용자 계정을 변수에 저장한다.
# 3. for문을 돌면서 다음 프로세스를 수행한다.
#   3-1. 패스워드 설정 주기가 설정되어 있는지 chage -l 명령어를 이용해 확인한다.
#   3-2. 설정되어 있지 않다면, 패스워드 설정 주기를 90일로 설정한다.
#   3-3. 설정 정보를 확인한다.


# -----------------------------------------------------------------------------------------------------------------------------------------------------

# 대상 서버와 계정 정보 변수 저장
hosts="host01 host02"
account="root test01 test02"

# 대상 서버만큼 반복
for host in $hosts; do

    echo "###### $host ######"
    for user in $account; do
        # 패스워드 설정 주기 체크
        pw_chk=$(ssh -q root@$host "chage -l $user | grep 9999 | wc -l")
        if [[ $pw_chk -eq 1 ]]; then
            # 패스워드 설정 주기를 90일로 설정
            ssh -q root@$host "chage -d $(date +%Y-%m-%d) -M 90 $user" 
            echo "=====> $user"
            # 설정 결과 확인
            ssh -q root@$host "chage -l $user"
        fi
    done
done