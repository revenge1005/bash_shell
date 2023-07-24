#!/bin/bash

#> nfs 스토리지 마운트

#> 프로세스
# 1. 마운트할 대상 NFS 서버 경로를 변수에 저장
# 2. 마운트할 디렉터리명을 변수에 저장
# 3. 마운트할 디렉터리가 있는지 체크 후 디렉터리를 생성
# 4. 생성한 디렉터리에 마운트 대상 NFS를 기본 옵션으로 마운트한다.
# 5. 마운트가 되면 mount 명령어를 이용하여 마운트된 디렉터리의 NFS 정보를 확인
# 6. /etc/fstab에 해당 정보를 추가
# 7. /etc/fsatb을 열어 추가된 정보를 확인

# 변수에 마운트 대상 NFS 경로 및 디렉토리 저장 
nfs_server="nfs.host01:/temp"
nfs_dir=/nfs_temp

# 마운트할 디렉토리가 있는지 체크후 없으면 디렉토리 생성
if [ ! -d $nfs_dir ]; then mkdir -p $nfs_dir; fi

# Check if NFS is installed
if ! rpm -q nfs-utils > /dev/null; then
  echo "NFS is not installed. Installing NFS..."
  
  # Install NFS
  sudo yum install -y nfs-utils
  
  # Start NFS service
  sudo systemctl start nfs-server
  sudo systemctl enable nfs-server
  
  echo "NFS installed and started successfully."
else
  echo "NFS is already installed."
fi

# 해당 NFS와 디렉토리 마운트
mount -t nfs $nfs_server $nfs_dir

# 마운트 정보에서 마운트 타입과 옵션 추출
nfs_type=$(mount | grep $nfs_dir | awk '{print $5}')
nfs_opt=$(mount | grep $nfs_dir | awk '{print $6}' | awk -F ',' '{print $1","$2","$3}')

# 추출한 마운트 정보를 조합하여 /etc/fstab에 설정
echo "$nfs_server  $nfs_dir  $nfs_type  ${nfs_opt:1}  1  1" >> /etc/fstab

# 설정한 /etc/fstab 내용 확인
cat /etc/fstab | grep $nfs_dir 

# 마운트 된 디렉토리 정보 확인
df -h | grep $nfs_dir