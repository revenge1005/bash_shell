#!/bin/bash

#> 패스워드 생성 법칙 적용
# 패스워드 생성 법칙은 pam_pwquality라는 라이버러리에 의해 설정되고 관리된다.
# 페도라 계열에서는 기본적으로 탑재되어 있지만, 데비안 계열에서는 패스워드 생성 법칙을 적용하기 위해서 libpam-pwquality라는 패키지를 별도로 설치해야 한다.

#> 필요한 정보
# 페도라 계열의 리눅스 환경 설정파일 경로 : /etc/pam.d/system-auth
# 데비안 계열의 리눅스 환경 설정파일 경로 : /etc/pam.d/common-password
# 패스워드 생성 법칙 항목들과 의미
#   ㆍRetry     : 패스트워드 입력 실패 시 재시도 횟수
#   ㆍMinlen    : 최소 패스워드 길이
#   ㆍDifok     : 이전 비밀번호와 유사한 문자 개수
#   ㆍLcredit   : 소문자 최소 요구 개수
#   ㆍUcredit   : 대문자 최소 요구 개수
#   ㆍDcredit   : 숫자 최소 요구 개수
#   ㆍOcredit   : 특수 문자 최소 요구 개수

#> 프로세스
# 1. 운영체제 타입을 확인한다.
#   1-1. 페도라 계열의 리눅스면 /etc/pam.d/system-auth 파일에 설정 적용한다.
#   1-2. 데비안 계열의 리눅스면 /etc/pam.d/common-password 파일에 있는지 확인한다.
#       1-2-1. 파일이 없으면 libpam-pwquality 패키지를 설치한다.
#       1-2-2. 파일이 있으면 /etc/pam.d/common-password에 설정을 적용한다.


# -----------------------------------------------------------------------------------------------------------------------------------------------------


# 운영체제 타입 확인
ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

# 운영체제가 페도라 계열일 경우
if [[ $ostype == *"rhel"* || $ostype == *"centos"* || $ostype == *"fedora"* ]]; then
    # 설정 여부 체크
    conf_check=$(cat /etc/pam.d/system-auth | grep 'local_users_only$' | wc -l)
    # 설정이 안되어 있으면 설정 후 설정 내용 확인
    if [ $conf_check ]; then
        sed -i 's/\(local_users_only$\)/\1 retry=3 authtok_type= minlen=8 lcredit=1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root/g' /etc/pam.d/system-auth
        cat /etc/pam.d/system-auth | grep 'password[[:space:]]*requisite'
    fi
elif [[ $ostype == "debian" ]]; then
    # pam_pwquality.so가 설치되어 있는지 설정파을을 통해 확인
    conf_check=$(cat /etc/pam.d/common-password | grep 'pam_pwquality.so' | wc -l)
    # 설치가 안되어 있으면 libpam-pwquality 설치
    if [ $conf_check -eq 0 ]; then
        apt install libpam-pwquality
    fi
    # 설정 여부 체크
    conf_check=$(cat /etc/pam.d/common-password | grep 'retry=3$' | wc -l)
    # 설정이 안되어 있으면 설정 후 설정 내용 확인
    if [ $conf_check -eq 1 ]; then
        sed -i 's/\(retry=3$\)/\1 minlen=8 maxrepeat=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 difok=3 gecoscheck=1 reject_username enforce_for_root/g' /etc/pam.d/common-password
        echo "================================================="
        cat /etc/pam.d/common-password | grep '^password[[:space:]]*requisite'
    fi
fi