#!/usr/bin/env bash
set -e

echo "=== Cloudreve Docker Installer ==="

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

apt update
apt install -y ca-certificates curl gnupg

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

if ! docker compose version >/dev/null 2>&1; then
  apt install -y docker-compose-plugin
fi

BASE_DIR="/opt/cloudreve"
mkdir -p ${BASE_DIR}/{uploads,config,data}
cd ${BASE_DIR}

cat <<'YAML' > docker-compose.yml
version: "3.8"

services:
  cloudreve:
    image: cloudreve/cloudreve:latest
    container_name: cloudreve
    restart: unless-stopped
    ports:
      - "5212:5212"
    volumes:
      - ./uploads:/cloudreve/uploads
      - ./config:/cloudreve/config
      - ./data:/cloudreve/data
    environment:
      - TZ=Asia/Taipei
YAML

docker compose up -d

docker logs cloudreve | tail -n 20
