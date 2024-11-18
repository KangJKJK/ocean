#!/bin/bash

# 색깔 변수 정의
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 필수 패키지 설치
echo -e "${BOLD}${CYAN}필수 패키지 설치 중...${NC}"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y ufw

# Docker GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Docker 저장소 추가
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Docker 설치
sudo apt-get update
sudo apt-get install -y docker-ce

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Docker 서비스 시작
sudo systemctl start docker

# Docker 서비스가 부팅 시 자동으로 시작되도록 설정
sudo systemctl enable docker

# 사용 중인 포트 확인
echo -e "${BOLD}${CYAN}현재 사용 중인 포트를 확인합니다...${NC}"
used_ports=$(netstat -tuln | awk '{print $4}' | grep -E ':(8000|8100|9000|9100)' | cut -d':' -f2)

if [ -z "$used_ports" ]; then
    echo -e "${YELLOW}사용 중인 포트가 없습니다. 안전하게 포트를 선택할 수 있습니다.${NC}"
else
    echo -e "${BOLD}${CYAN}현재 사용 중인 포트:${NC}"
    echo "$used_ports"
    echo -e "${YELLOW}위의 포트 번호를 피하기 위해 이용중인 포트번호들을 기록해두세요.${NC}"
    read -q "확인 후 Enter 키를 눌러 계속 진행하세요... "
fi

echo -e "${BOLD}${CYAN}노드 설치중 프라이빗키를 요구하는데 앞에 0x를 꼭 붙여주세요${NC}"
read -q "설치가 시작되고 난 후 본인이 입력한 port번호들을 꼭 기억해두세요.(총 4개의 port번호)"
echo -e "${BOLD}${CYAN}설치파일을 다운받습니다...${NC}"
curl -O https://raw.githubusercontent.com/oceanprotocol/ocean-node/main/scripts/ocean-node-quickstart.sh && chmod +x ocean-node-quickstart.sh && ./ocean-node-quickstart.sh

echo -e "${BOLD}${CYAN}노드를 구동합니다...${NC}"
docker-compose up -d

# 포트 번호 입력 받기
echo -e "${BOLD}${CYAN}본인이 입력한 4개의 포트 번호를 입력하세요 (쉼표로 구분): ${NC}"
read -r ports_input

# 포트 번호를 배열로 변환
IFS=',' read -r -a ports <<< "$ports_input"

# 각 포트에 대해 ufw allow 명령어 실행
for port in "${ports[@]}"; do
    sudo ufw allow "$port/tcp"
done

echo -e "${BOLD}${CYAN}아래는 당신의 PeerID입니다. 적어두세요.${NC}"
docker-compose logs -f | grep "peerID"

echo -e "${BOLD}${CYAN}노드를 구동한 다음날 이곳에 접속하세요: https://nodes.oceanprotocol.com${NC}"
echo -e "${BOLD}${CYAN}Search칸에서 peerID를 입력하여 제대로 구동중인지 확인하세요${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
