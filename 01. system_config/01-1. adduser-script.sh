#!/bin/bash

# << 사용자 계정 생성 >>

# 사용자 계정 및 패스워드가 입려되었는지 확인
if [[ -n $1 ]] && [[ -n $2 ]]
then

    UserList=($1)
    Password=($2)

    # ${배열변수명[@]} : 해당 변수의 길이
    for (( i=0; i < ${#UserList[@]}; i++ ))
    do
        # 입력한 사용자 계정이 있는지 확인
        if [[ $(cat /etc/passwd | grep ${UserList[$i]} | wc -l) == 0 ]]
        then
            useradd ${UserList[$i]}
            echo ${Password[$i]} | passwd ${UserList[$i]} --stdin
        else
            echo "this user ${UserList[$i]} is existing."
        fi
    done

else
    echo -e 'Please input user id and password. \nUsage: adduser-script.sh "user01 user02" "pw01 pw02"'
fi
        