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

# 도커 설치 확인
echo -e "${BOLD}${CYAN}Docker 설치 확인 중...${NC}"
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}Docker가 이미 설치되어 있습니다.${NC}"
else
    echo -e "${RED}Docker가 설치되어 있지 않습니다. Docker를 설치하는 중입니다...${NC}"
    sudo apt update && sudo apt install -y curl net-tools
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    echo -e "${GREEN}Docker가 성공적으로 설치되었습니다.${NC}"
fi
sudo apt-get install docker-compose

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

read -q "설치 진행중에 개인키를 입력하는 단계가 있습니다. 개인키 앞에 0x를 꼭 붙여서 입력하세요. (엔터)"
read -q "IP를 입력하는 단계가 있습니다. 본인의 VPS IP를 입력하세요. (엔터)"
echo -e "${BOLD}${CYAN}설치파일을 다운받습니다...${NC}"
curl -O https://raw.githubusercontent.com/oceanprotocol/ocean-node/main/scripts/ocean-node-quickstart.sh && chmod +x ocean-node-quickstart.sh && ./ocean-node-quickstart.sh

echo -e "${BOLD}${CYAN}노드를 구동합니다...${NC}"
docker-compose up -d
docker-compose logs -f

echo -e "${YELLOW}대시보드는 다음과 같습니다: https://nodes.oceanprotocol.com${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}
