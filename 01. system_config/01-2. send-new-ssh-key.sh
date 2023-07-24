#!/bin/bash

# 서버 주소 변수 설정
hosts=("host01" "host02" "host03")
pw="1234"

# SSH 키 생성
echo "[Generating SSH key...]"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q

# known_hosts 파일이 없으면 파일을 생성
known_hosts_file="$HOME/.ssh/known_hosts"
if [ ! -f "$known_hosts_file" ]; then
    touch "$known_hosts_file"
    chmod 600 "$known_hosts_file"
fi

# 기존에 등록된 호스트 키를 삭제하고 해당 호스트의 공개키를 가져와 known_hosts 파일에 등록
for host in "${hosts[@]}"; do
    ssh-keygen -R "$host" 2>/dev/null
    ssh-keyscan -H "$host" >> "$known_hosts_file" 2>/dev/null
done

# sshpass 명령이 없으면 설치
if ! command -v sshpass &> /dev/null; then
    echo "[sshpass is not installed. Installing...]"
    
    if command -v yum &> /dev/null; then
        sudo yum install -y sshpass >/dev/null 2>&1
    else
        echo "Package manager not found. Please install sshpass manually."
        exit 1
    fi
fi

# SSH 키 배포
echo "[Copying SSH key to remote servers...]"
for host in "${hosts[@]}"; do
    echo "[Copying SSH key to $host...]"
    sshpass -p "$pw" ssh-copy-id -i ~/.ssh/id_rsa.pub "$host" >/dev/null 2>&1
done

# 배포 완료 메시지 출력
echo "[SSH key deployment completed!]"