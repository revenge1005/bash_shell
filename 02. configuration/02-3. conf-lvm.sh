#!/bin/bash

#> lvm 환경 설정 변경
# LVM은 여러 디바이스를 하나의 볼륨으로 만들기 때문에 디바이스를 허용/거부할지 등을 filter 또는 global_fiter를 통해 설정한다.

#> 필요한 정보
# LVM 환경 설정파일 경로 - /etc/lvm/lvm.conf
# 설정될 환경 설정 항목 - global_filter

#> 프로세스
# 1. LVM 환경설정을 변경할 호스트 노드 목록을 변수에 저장한다.
# 2. for문을 돌면서 다음 프로세스를 처리
#   2-1. grep을 이용해 lvm.conf에서 global_filter가 주석되어 있는지 확인
#   2-2. 설정을 변경하기 전 백업
#   2-3. 주석 처리되어 있다면 sed를 이용해 설정 변경
#   2-4. 설정이 변경되었으면 lvm 관련 서비스들을 재시작

# 참고 자료
# https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/7/html/logical_volume_manager_administration/lvm_filters


# 설정 변경 대상 노드들
nodes="host01 host02 host03"
# 환경설정 확인 명령어
cmd1="cat /etc/lvm/lvm.conf | grep -e '^[[:space:]]*global_filter =' | wc -l"
# 환경설정 파일 백업 명령어
cmd2="cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak"
# 환경설정 변경 명령어
cmd3="sed -i 's/\(# global_filter =.*\)/\1\n	global_filter = [ ""r|.*|"" ]/g' /etc/lvm/lvm.conf"
# lvm관련 서비스 재시작 명령어
cmd4="systemctl restart lvm2*"

# stty -echo : 패스워드를 입력받을 때 외부로부터의 유출을 막기 위함
stty -echo
read -p "Please input Hosts password: " pw 
stty echo

if [[ -z $pw ]]; then echo -e "\nYou need a password for this script. Please retry script"; exit; fi

for node in $nodes
do
  echo -e "\n$node"
  conf_chk=$(sshpass -p $pw ssh root@$node $cmd1)
  if [[ conf_chk -eq 0 ]]; then
    # 설정 변경 전 백업.
    echo "lvm.conf backup"
    sshpass -p $pw ssh root@$node $cmd2
    # sed를 이용해 설정을 변경함.
    echo "lvm.conf reconfiguration"
    sshpass -p $pw ssh root@$node $cmd3
    # lvm 관련 서비스 재시작
    echo "lvm related service restart"
    sshpass -p $pw ssh root@$node $cmd4
  fi
done