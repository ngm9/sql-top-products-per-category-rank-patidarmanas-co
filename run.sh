#!/usr/bin/env bash
set -e

echo "[run.sh] Starting PostgreSQL container with docker-compose..."
docker-compose up -d

echo "[run.sh] Waiting for PostgreSQL to be ready and init_database.sql to commit..."
ready=0
for i in {1..45}; do
  if docker-compose exec -T postgres psql -U utkrusht -d ecom_analytics -tAc "SELECT to_regclass('public.fact_order_items') IS NOT NULL AND (SELECT count(*) FROM fact_order_items) > 0" 2>/dev/null | grep -q '^t$'; then
    echo "[run.sh] PostgreSQL is ready and init_database.sql has committed."
    ready=1
    break
  fi
  echo "[run.sh] PostgreSQL/init not ready yet, retrying in 2s... ($i/45)"
  sleep 2
done
if [ "$ready" -ne 1 ]; then
  echo "[run.sh] PostgreSQL did not become ready in time."
  docker-compose logs
  exit 1
fi

echo "[run.sh] Verifying fact table row count..."
if ! docker-compose exec -T postgres psql -U utkrusht -d ecom_analytics -c "SELECT COUNT(*) FROM fact_order_items;" >/dev/null 2>&1; then
  echo "[run.sh] Fact table fact_order_items is not accessible."
  docker-compose logs
  exit 1
fi

rows=$(docker-compose exec -T postgres psql -U utkrusht -d ecom_analytics -t -c "SELECT COUNT(*) FROM fact_order_items;")
rows=$(echo "$rows" | xargs)

echo "[run.sh] fact_order_items row count: $rows"

if [ "$rows" -lt 50000 ]; then
  echo "[run.sh] Fact table fact_order_items has too few rows: $rows"
  docker-compose logs
  exit 1
fi

echo "[run.sh] Database is ready. You can connect using:"
echo "psql -h <DROPLET_IP> -p 5432 -U utkrusht -d ecom_analytics"
