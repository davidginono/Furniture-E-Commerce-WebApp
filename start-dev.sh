#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -a PIDS=()

cleanup() {
  echo "Stopping dev services..."
  for pid in "${PIDS[@]:-}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  echo "All services stopped."
}

trap cleanup INT TERM

start_frontend() {
  cd "$ROOT_DIR/front-end/bigsofa-frontend"
  npm run dev
}

start_admin() {
  cd "$ROOT_DIR/admin_frontend"
  npm run dev
}

start_backend() {
  cd "$ROOT_DIR/backend/bigsofa-backend"
  ./mvnw spring-boot:run
}

echo "Starting customer frontend..."
start_frontend &
PIDS+=($!)

echo "Starting admin frontend..."
start_admin &
PIDS+=($!)

echo "Starting Spring Boot backend..."
start_backend &
PIDS+=($!)

echo "All services started. Press Ctrl+C to stop."

wait "${PIDS[@]}"
