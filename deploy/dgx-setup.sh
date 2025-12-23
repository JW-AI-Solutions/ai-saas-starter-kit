#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}DGX Inference Server Setup${NC}"
echo -e "${GREEN}================================${NC}\n"

# Configuration
PROJECT_NAME="ai-saas-starter-kit"
DEPLOY_DIR="${HOME}/projects"
PROJECT_DIR="${DEPLOY_DIR}/${PROJECT_NAME}"
GIT_REPO="git@github.com:JW-AI-Solutions/${PROJECT_NAME}.git"

echo -e "${YELLOW}Step 1: Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not found. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 2: Checking NVIDIA Container Toolkit...${NC}"
if ! docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo -e "${RED}NVIDIA Container Toolkit not working. Please check installation.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GPU access verified${NC}"

echo -e "${YELLOW}Step 3: Setting up project directory...${NC}"
mkdir -p ${DEPLOY_DIR}
cd ${DEPLOY_DIR}

if [ -d "${PROJECT_DIR}" ]; then
    echo -e "${YELLOW}Repository exists. Pulling latest changes...${NC}"
    cd ${PROJECT_DIR}
    git pull
else
    echo -e "${YELLOW}Cloning repository...${NC}"
    git clone ${GIT_REPO} ${PROJECT_DIR}
    cd ${PROJECT_DIR}
fi

echo -e "${YELLOW}Step 4: Building and starting inference server...${NC}"
docker-compose -f docker-compose.dgx.yml down
docker-compose -f docker-compose.dgx.yml up -d --build

sleep 5

echo -e "${YELLOW}Step 5: Testing inference server...${NC}"
DGX_IP=$(hostname -I | awk '{print $1}')

if curl -f http://localhost:8000/health; then
    echo -e "\n${GREEN}✓ Inference server is running${NC}"
else
    echo -e "\n${YELLOW}⚠ Server test failed. Check logs with:${NC}"
    echo -e "  docker-compose -f docker-compose.dgx.yml logs -f"
    exit 1
fi

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}\n"

echo -e "${GREEN}Access Information:${NC}"
echo -e "  API Endpoint: ${YELLOW}http://${DGX_IP}:8000${NC}"
echo -e "  Health Check: ${YELLOW}curl http://${DGX_IP}:8000/health${NC}"
echo -e "  API Docs:     ${YELLOW}http://${DGX_IP}:8000/docs${NC}"

echo -e "\n${GREEN}Container Management:${NC}"
echo -e "  Status:  ${YELLOW}docker-compose -f docker-compose.dgx.yml ps${NC}"
echo -e "  Logs:    ${YELLOW}docker-compose -f docker-compose.dgx.yml logs -f${NC}"
echo -e "  Restart: ${YELLOW}docker-compose -f docker-compose.dgx.yml restart${NC}"
echo -e "  Stop:    ${YELLOW}docker-compose -f docker-compose.dgx.yml down${NC}"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "  1. Update main.py to point to your NIM containers"
echo -e "  2. Pull NIM images: docker pull nvcr.io/nim/..."
echo -e "  3. Add NIM services to docker-compose.dgx.yml\n"
