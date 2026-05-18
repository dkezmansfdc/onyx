#!/bin/bash
set -e

SERVER="onyx@alexandria.coredev.com"
REMOTE_DIR="/home/onyx/onyx"
COMPOSE_DIR="$REMOTE_DIR/deployment/docker_compose"

echo "🚀 Deploying Onyx to production..."

echo "📤 Pushing to GitHub..."
git push origin main

echo "📥 Pulling on server..."
ssh $SERVER "cd $REMOTE_DIR && git pull origin main"

echo "🔨 Building from source..."
ssh $SERVER "cd $COMPOSE_DIR && docker compose -f docker-compose.prod.yml build --no-cache api_server background web_server"

echo "🔄 Restarting..."
ssh $SERVER "cd $COMPOSE_DIR && docker compose -f docker-compose.prod.yml up -d --no-deps api_server background web_server"

echo "✅ Checking health..."
sleep 10
ssh $SERVER "cd $COMPOSE_DIR && docker compose -f docker-compose.prod.yml ps"

echo "🎉 Deploy complete!"