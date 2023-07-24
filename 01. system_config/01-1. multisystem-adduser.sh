#!/bin/bash

# 여러 대의 시스템에 사용자 새성 및 패스워드 설정

for server in "host01 host02 host03"
do
    echo $server
    ssh root@$server "useradd $1"
    ssh root@$server "echo $2 | passwd $1 --stdin"
done