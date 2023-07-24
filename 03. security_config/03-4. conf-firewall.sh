#!/bin/bash

#> Firewall에 포트 추가 
# 레드헷이나 CentOS는 iptalbes에서 firewalld로 방화벽이 변경되었다.
# 데비안 계열의 리눅스의 경우에는 ufw를 사용한다.

#> 필요한 정보
# firewalld에서 서비스 포트 추가 명령 : firewall-cmd --add-service=[service name]
# firewalld에서 포트 추가 명령 : firewall-cmd --add-port=[port/protocol]
# ufw에서 서비스 포트 추가 명령 : ufw allow [service name | port/protocol]


#> 프로세스
# 1. 운영체제 타입이 페도라 계열인지 데비안 계열인지 확인
#   1-1-1. 페도라 계열이면 시스템에 firewalld가 실행 중인지 확인
#   1-1-2. 운영체제가 페도라 계열이면 firewall-cmd 명령어를 이용해 포트를 추가
#   1-2-1. 데비안 계열이면 시스템에 ufw가 실행 중인지 확인
#   1-2-2. 운영체제가 데비안이면 ufw 명령어를 이용해 포트를 추가

# 운영체제 타입 확인
ostype=$(cat /etc/*release | grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

read -p "Please input ports(ex: http 123/tcp 123/udp) : " ports

if [[ -z $ports ]]; then echo "You didn't input port. Please retry."; exit; fi

# 운영체제가 페도라 계열일 경우
if [[ $ostype == *"rhel"* || $ostype == *"centos"* || $ostype == *"fedora"* ]]; then

    run_chk=$( firewall-cmd --state )
    if [[ $run_chk == "running" ]]; then

        for port in $ports; do
            # service port 인지 일반 port인지 체크
            chk_port=$(echo $port | grep '^[a-zA-Z]' | wc -l)
            if [[ chk_port -eq 1 ]]; then
                firewall-cmd --add-service=$port
                firewall-cmd --add-service=$port --permanent
            else
                firewall-cmd --add-port=$port
                firewall-cmd --add-port=$port --permanent
            fi
        done
        # port 추가 결과 확인
        firewall-cmd --list-all
    fi

# 운영체제가 데비안 계열일 경우
elif [[ $ostype == "debian" ]]; then

    run_chk=$( ufw status | grep ": active" | wc -l )
    if [[ $run_chk -eq 1 ]]; then
        for port in $ports; do
            ufw allow $port
        done
        ufw status numbered
    fi
fi