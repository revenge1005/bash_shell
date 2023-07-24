#!/bin/bash

#> 사설 인증서 생성
# 공인 인증서는 서비스를 할 때 발급받아 사용하며, 그 외에 내부 서비스나 개발용으로는 사설 인증서를 주소 생성하여 사용한다.

#> 필요한 정보
# RSA 개인키 생성 명령 : openssl genrsa
# 자체 서명된 Root CA 인증서 생성 명령 : openssl req
# 자체 CA 인증서와 클라이언트키를 이용하여 클라이언트 인증키 생성 명령 : openssl ca
# 명령별 상세 옵션 설명 확인 : man genrsa, man req, man ca


#> 프로세스
# 1. 자체 서명된 Root CA 인증서가 생성될 디렉터리를 생성
# 2. CA 디렉터리에 빈 index.txt와 1000이 입력된 serial을 생성
# 3. 인증 기관용(CA) 개인 키와 인증서 생성
# 4. 클라이언트에 인증기관용 인증서 추가
# 5. 추가한 인증서가 믿을 수 있는 인증서라고 설정
# 6. 서버에서 사용할 SSL/TLS 서버 키를 만든다.
# 7. 서버에서 사용할 인증요청서를 만든다.
# 8. 서버의 인증 요청서를 이용하여 CA에서 인증서를 발급받는다.


# -------------------------------------------------------------------------------------------------------------------


# 서명용 호스트 초기화
echo "=========================="
echo " Initializing sining host "
echo "=========================="
touch  index.txt
echo '1000' | tee /etc/pki/CA/serial

# 인증 기관용 인증서 생성
echo "=================================="
echo " Creating a certificate authority "
echo "=================================="
echo "---------------------"
echo " Generate rsa ca key "
echo "---------------------"
openssl genrsa -out ca.key.pem 4096
echo "--------------------------"
echo " Generate rsa ca cert key "
echo "--------------------------"
openssl req -key ca.key.pem -new -x509 -days 7300 -extensions v3_ca -out ca.crt.pem

# 클라이언트에 인증기관용 인증서
echo "============================================="
echo " Adding the certificate authority to clients "
echo "============================================="
echo "cp ca.crt.pem /etc/pki/ca-trust/source/anchors/"
cp ca.crt.pem /etc/pki/ca-trust/source/anchors/
echo "update-ca-trust extract"
update-ca-trust extract

# SSL/TLS 키 생성
echo "========================="
echo " Creating an SSL/TLS key "
echo "========================="
cp /etc/pki/tls/openssl.cnf .
openssl req -config openssl.cnf -key server.key.pem -new -out server.csr.pem

# SSL/TLS 인증서 생성
echo "=================================="
echo " Creating the SSL/TLS certificate "
echo "=================================="
openssl ca -config openssl.cnf -extensions v3_req -days 3650 -in server.csr.pem -out server.crt.pem -cert ca.crt.pem -keyfile ca.key.pem
