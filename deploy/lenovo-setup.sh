#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}AI SaaS Starter Kit - Lenovo Setup${NC}"
echo -e "${GREEN}================================${NC}\n"

# Configuration
PROJECT_NAME="ai-saas-starter-kit"
DEPLOY_DIR="/opt/docker-apps"
PROJECT_DIR="${DEPLOY_DIR}/${PROJECT_NAME}"
GIT_REPO="git@github.com:JW-AI-Solutions/${PROJECT_NAME}.git"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root or with sudo${NC}" 
   exit 1
fi

echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"
apt-get update
apt-get install -y git docker.io docker-compose curl vim htop

systemctl enable docker
systemctl start docker

if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
fi

echo -e "${YELLOW}Step 2: Creating directory structure...${NC}"
mkdir -p ${DEPLOY_DIR}
cd ${DEPLOY_DIR}

echo -e "${YELLOW}Step 3: Cloning repository...${NC}"
if [ -d "${PROJECT_DIR}" ]; then
    cd ${PROJECT_DIR}
    git pull
else
    git clone ${GIT_REPO} ${PROJECT_DIR}
    cd ${PROJECT_DIR}
fi

echo -e "${YELLOW}Step 4: Creating environment file...${NC}"
mkdir -p .envs/.staging

if [ ! -f ".envs/.staging/.django" ]; then
    read -p "Enter your DGX IP address: " DGX_IP
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
    LENOVO_IP=$(hostname -I | awk '{print $1}')
    
    cat > .envs/.staging/.django << ENVEOF
DEBUG=False
SECRET_KEY=${SECRET_KEY}
DJANGO_SETTINGS_MODULE=config.settings.staging
ALLOWED_HOSTS=lenovo.local,${LENOVO_IP},localhost

DATABASE_URL=postgres://postgres:postgres@db:5432/ai_platform_staging
REDIS_URL=redis://redis:6379/0
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0

DGX_API_URL=http://${DGX_IP}:8000
DGX_API_KEY=
ENVEOF
fi

echo -e "${YELLOW}Step 5: Starting containers...${NC}"
docker-compose -f docker-compose.staging.yml down
docker-compose -f docker-compose.staging.yml up -d --build

sleep 10

echo -e "${YELLOW}Step 6: Running migrations...${NC}"
docker-compose -f docker-compose.staging.yml exec -T web python manage.py migrate

echo -e "\n${GREEN}✓ Deployment Complete!${NC}"
echo -e "Access: ${YELLOW}http://${LENOVO_IP}${NC}"
