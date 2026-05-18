#!/bin/bash
set -e
 
# ─── Configuration ─────────────────────────────────────────────
SERVER="onyx@alexandria.coredev.com"
REMOTE_DIR="/home/onyx/onyx"
COMPOSE_DIR="$REMOTE_DIR/deployment/docker_compose"
COMPOSE_CMD="docker compose -f docker-compose.prod.yml"
 
# ─── Parse arguments ───────────────────────────────────────────
SKIP_PUSH=false
BACKEND_ONLY=false
FRONTEND_ONLY=false
FULL_REBUILD=false
 
for arg in "$@"; do
  case $arg in
    --skip-push)    SKIP_PUSH=true ;;
    --backend)      BACKEND_ONLY=true ;;
    --frontend)     FRONTEND_ONLY=true ;;
    --full-rebuild) FULL_REBUILD=true ;;
    --help)
      echo "Usage: ./deploy.sh [options]"
      echo ""
      echo "Options:"
      echo "  --skip-push      Don't push to GitHub (deploy whatever is on the server)"
      echo "  --backend        Only rebuild backend (api_server + background)"
      echo "  --frontend       Only rebuild frontend (web_server)"
      echo "  --full-rebuild   Build with --no-cache (slow, use after Dockerfile changes)"
      echo ""
      echo "Examples:"
      echo "  ./deploy.sh                    # Full deploy (push + build all + restart)"
      echo "  ./deploy.sh --backend          # Only rebuild and restart backend"
      echo "  ./deploy.sh --frontend         # Only rebuild and restart frontend"
      echo "  ./deploy.sh --skip-push        # Deploy what's already pushed"
      exit 0
      ;;
  esac
done
 
# ─── Determine which services to build ─────────────────────────
if $BACKEND_ONLY; then
  BUILD_SERVICES="api_server background"
  RESTART_SERVICES="api_server background"
  echo "🔧 Backend-only deploy"
elif $FRONTEND_ONLY; then
  BUILD_SERVICES="web_server"
  RESTART_SERVICES="web_server"
  echo "🎨 Frontend-only deploy"
else
  BUILD_SERVICES="api_server background web_server"
  RESTART_SERVICES="api_server background web_server"
  echo "🚀 Full deploy"
fi
 
BUILD_FLAGS=""
if $FULL_REBUILD; then
  BUILD_FLAGS="--no-cache"
  echo "⚠️  Full rebuild (no cache) — this will take a while"
fi
 
# ─── Step 1: Push to GitHub ────────────────────────────────────
if ! $SKIP_PUSH; then
  echo "📤 Pushing to GitHub..."
  git push origin main
fi
 
# ─── Step 2: Pull on server ────────────────────────────────────
echo "📥 Pulling on server..."
ssh $SERVER "cd $REMOTE_DIR && git pull origin main"
 
# ─── Step 3: Build ─────────────────────────────────────────────
echo "🔨 Building: $BUILD_SERVICES"
ssh $SERVER "cd $COMPOSE_DIR && $COMPOSE_CMD build $BUILD_FLAGS $BUILD_SERVICES"
 
# ─── Step 4: Restart services ──────────────────────────────────
# --no-deps prevents restarting Postgres, Redis, Vespa, etc.
echo "🔄 Restarting: $RESTART_SERVICES"
ssh $SERVER "cd $COMPOSE_DIR && $COMPOSE_CMD up -d --no-deps $RESTART_SERVICES"
 
# ─── Step 5: Wait for API server to be ready ───────────────────
if [[ "$RESTART_SERVICES" == *"api_server"* ]]; then
  echo "⏳ Waiting for API server..."
  ssh $SERVER "
    for i in \$(seq 1 30); do
      if docker exec \$(docker ps -q -f name=onyx-api_server) curl -sf http://localhost:8080/health > /dev/null 2>&1; then
        echo 'API server is ready'
        break
      fi
      echo \"  Attempt \$i/30...\"
      sleep 5
    done
  "
fi
 
# ─── Step 6: Restart Nginx to pick up new upstream IPs ─────────
echo "🔄 Restarting Nginx..."
ssh $SERVER "cd $COMPOSE_DIR && $COMPOSE_CMD restart nginx"
 
# ─── Step 7: Verify ───────────────────────────────────────────
echo "✅ Verifying..."
sleep 3
ssh $SERVER "cd $COMPOSE_DIR && $COMPOSE_CMD ps --format 'table {{.Name}}\t{{.Status}}'"
 
echo ""
echo "🎉 Deploy complete!"