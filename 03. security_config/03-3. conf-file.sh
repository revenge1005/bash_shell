#!/bin/bash

#> 디렉터리 및 파일 접근 권한 변경할 때
# Sticky bit, SUID(Set User ID), SGID(Set Group ID)가 설정된 파일들은 특정 명령어를 실행하여 root 권한 획득 및 서비스의 장애를 발생시킬 수 있다.
# 따라서 불필요한 파일에 Sticky bit, SUID, SGID가 설정되어 있지 않도록 관리해야 한다.
# 또한 모든 사용자가 접근 및 수정할 수 있는 권한을 가진 파일이 존재할 경우 일반 사용자의 실수로 중요 정보 누출, 시스템 장애를 발생 시킬 수 있는데 이런 파일을 World Writable 파일이라고 한다.
# 따라서 시스템을 구축할 경우나 운영할 경우 주기적으로 이런 디렉터리 및 파일 접근권한을 모니터링하고 조치해야 한다.


#> 필요한 정보
# SID 설정파일을 찾기 위한 명령         : find / -perm -04000
# GID 설정파일을 찾기 위한 명령         : find / -perm -02000
# Sticky bit 설정파일을 찾기 위한 명령  : find / -perm -01000
# World Writable 파일 또는 디렉터리 찾기 위한 명령  : find / -xdev -perm -2
# -xdev 옵션은 xfs 이외의 파일 시스템은 검색하지 않는다.
# -xdev 옵션을 사용하지 않으면 xfs 파일시스템 이외에 proc, sysfs, debug, cgroup, tmpfs, mqueue와 같은 파일시스템 유형을 가진 파일 경로까지 모두 검색한다.
#   ㆍProc      : 커널 프로세스를 포함하여 실행 중인 프로세스들을 위한 디렉터리 및 파일 유형
#   ㆍSysfs     : 리눅스 커널이 제공하는 가상 파일시스템을 위한 디렉터리 및 파일 유형
#   ㆍDebugfs   : 파일시스템을 디버깅하기 위한 파일 및 디렉터리 유형
#   ㆍcgroup    : 컨테이너 기술에 사용되며, 프로스세들이 사용하는 컴퓨팅 자원을 제한하고 격리함
#   ㆍTmpfs     : 메모리를 디스크처럼 쓸 수 있는 파일 시스템
#   ㆍMquue     : 시스템의 메시지 큐를 읽기 위한 파일 시스템
#   ㆍXfs       : 고성능 64비트 저널링 파일 시스템


#> 프로세스
# 1. SUID, SGID, Sticky bit가 설정된 파일 및 디렉터리를 찾는다.
# 2. World Writable 디렉터리 및 파일을 찾는다.
# 3. 찾은 파일 목록을 보여주고, 권한 변경 여부를 묻는다.
# 4. Y를 선택하면 Sticky bit 파일은 644로 권한을 변경한다.
#   4-1. World Writable 파일의 경우는 기타 사용자의 쓰기 권한을 제거한다.
#   4-2. 모든 파일의 권한 변경이 완료되면 결과를 보여준다.
# 5. N를 선택하면 스크립트가 종료된다.
# 6. 엔터 키를 누르면 아무것도 입력하지 않았다는 메시지를 보여준 후 스크립트를 종료한다.
# 7. 이외에는 글자를 잘못 입력했다는 메시지를 보여준 후 스크립트를 종료한다.


echo "=== SUID, SGID, Sticky Bit ==="
# 검색된 파일이나 디렉터리 중 SID, GID, Sticky Bit를 가지면 안되는 주요 파일 결로를 grep을 이용해 검색하고 해당 결과는 s_file에 저장
s_file=$(find / -xdev -perm -04000 -o -perm -02000 -o -perm 01000 2>/dev/null | grep -e 'dump$' -e 'lp*-lpd$' -e 'newgrp$' -e 'restore$' -e 'at$' -e 'traceroute$')

# 명령 실행 결과를 xargs ls -dl을 사용하여 검색된 파일 경로를 xargs로 받아 파라미터로 사용하여 ls -dl 명령어를 실행함으로써 상세 파일 목록을 조회
find / -xdev -perm -04000 -o -perm -02000 -o -perm 01000 2>/dev/null | grep -e 'dump$' -e 'lp*-lpd$' -e 'newgrp$' -e 'restore$' -e 'at$' -e 'traceroute$' | xargs ls -dl

echo -e "\n=== World Writable Path ==="
w_file=$(find / -xdev -perm -2 -ls | grep -v 'l..........' | awk '{print $NF}')
# 쓰기 권한을 가진 파일이나 디렉터리를 검색, 이렇게 검색된 파일 목록을 grep -v 'l..........'을 통해서 l로 시작하는 심볼릭 링크를 검색에서 제외하고 나머지 결과만 추출한다.
find / -xdev -perm -2 -ls | grep -v 'l..........' | awk '{print $NF}' | xargs ls -dl

echo ""
read -p "Do you want to change file permission(y/n) " result

if [[ $result == "y" ]]; then

    # 변경 작업 시작
    echo -e "\n=== Chmod SUID, SGID, Sticky bit Path ==="
    for file in $s_file; do
        echo "chmod -s $file"
        chmod -s $file
    done

    echo -e "\n=== Chmod World Writable Path ==="
    for file in $w_file; do
        echo "chmod o-w $file"
        chmod o-w $file
    done

    # 결과 확인
    echo -e "\n=== Result of Sticky bit Path ==="
    for file in $s_file; do
        ls -dl $file
    done

    echo -e "\n=== Result of World Writable Path ==="
    for file in $w_file; do
        ls -dl $file
    done

# 파일권한 변경을 원하지 않을 경우
elif [[ $result == "n" ]]; then
    exit

# 파일권한 변경여부 질의에 아무것도 입력하지 않았을 경우
elif [[ -z $result ]]; then
    echo "Yon didn't have any choice. Please check these files for security."
    exit

# 파일권한 변경여부 질의에 아무 글자 입력했을 경우
else
    echo "You can chose only y or n."
    exit
fi