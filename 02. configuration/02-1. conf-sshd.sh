#!/bin/bash

#> sshd 환경 설정 변경

#> 많이 사용되는 환경 설정
# Port - SSH 기본 포트인 22번을 다른 번호로 변경할 때 사용
# PermitRootLogin - root 계정으로 SSH 접근을 허용할지에 여부
# PasswordAuthentication - 패스워드를 이용한 인증을 허용할지에 대한 여부
# PubkeyAuthentication - 퍼블릭키를 이용한 인증을 허용할지에 대한 여부

#> 프로세스
# 1. 환경 설정 파일 경로를 변수에 저장
# 2. Switch~case 문을 이용하여 해당 번호를 입력받으면 환경 설정을 변경
# 3. 해당 경로에서 해당 항목을 찾아 sed를 이용하여 값을 변경하고, 파일에 적용
# 4. 설정 변경이 되었으면 SSH 서비스를 재시작
# 5. OS가 레드헷 리눅스고, Port를 변경했다면 Selinux 설정을 변경


conf_path=/etc/ssh/sshd_config

function restart_system(){
    echo "[Restart sshd...]"
    systemctl restart sshd
}

function selinux(){
    # OS가 레드햇 리눅스고, port를 수정했을 경우
    if [[ $(cat /etc/*release | grep -i redhat | wc -l) > 1 ]] && [[ $1 == 1 ]]
    then
        # SElinux에 해당 port 추가
        echo "[Add port $port to selinux...]"
        semanage port -a -t ssh_port_t -p tcp $port
    fi
}

# 환경 설정파일 백업
cp $conf_path ${conf_path}.bak.$(date +%Y%m%d)

case $1 in
    1)
    # Port 변경
    read -p "Please input port: " port
    exist_conf=$(cat $conf_path | grep -e '^#Port' -e '^port')
    sed -i "s/$exist_conf/Port $port/g" $conf_path
    restart_system
    selinux $1
    ;;
    2)
    # PermitRootLogin 변경
    read -p "Please input PermitRootLogin yes or no: " rootyn
    exist_conf=$(cat $conf_path | grep -e '^#PermitRootLogin' -e '^PermitRootLogin')
    sed -i "s/$exist_conf/PermitRootLogin $rootyn/g" $conf_path
    restart_system
    ;;
    3)
    # PasswordAuthentication 변경
    read -p "Please input PasswordAuthentication yes or no: " pwyn
    exist_conf=$(cat $conf_path | grep -e '^#PasswordAuthentication' -e '^PasswordAuthentication')
    sed -i "s/$exist_conf/PasswordAuthentication $pwyn/g" $conf_path
    restart_system
    ;;
    4)
    # PubkeyAuthentication 변경
    read -p "Please input PubkeyAuthentication yes or no: " keyyn
    exist_conf=$(cat $conf_path | grep -e '^#PubkeyAuthentication' -e '^PubkeyAuthentication')
    sed -i "s/$exist_conf/PubkeyAuthentication $keyyn/g" $conf_path
    restart_system
    ;;
    *)
    echo "Please input with following number"
    echo "1) Port   2) PermitRootLogin  3) PasswordAuthentication   4) PubkeyAuthentication"
    echo "Usage: conf-sshd.sh 2"
esac