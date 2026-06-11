#!/usr/bin/env bash
set -e

echo "[kill.sh] Changing directory to /root/task..."
cd /root/task || true

echo "[kill.sh] Bringing down docker-compose services and removing volumes/images..."
docker-compose down --rmi all --volumes --remove-orphans || true

echo "[kill.sh] Stopping any remaining running containers..."
docker stop $(docker ps -q) >/dev/null 2>&1 || true

echo "[kill.sh] Removing all containers..."
docker rm $(docker ps -aq) >/dev/null 2>&1 || true

echo "[kill.sh] Pruning Docker volumes..."
docker volume prune -f || true

echo "[kill.sh] Pruning Docker images..."
docker image prune -a -f || true

echo "[kill.sh] Performing final system prune..."
docker system prune -a --volumes -f || true

echo "[kill.sh] Removing /root/task directory..."
rm -rf /root/task || true

echo "[kill.sh] Cleanup completed."
