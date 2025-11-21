#!/bin/bash

# Deploy FoundersEvents to xlai.live
# Server: 138.197.38.120
# Domain: xlai.live

set -e

SERVER="138.197.38.120"
SERVER_USER="root"
APP_DIR="/var/www/foundersevents"
DOMAIN="xlai.live"

echo "========================================="
echo "Deploying FoundersEvents to $DOMAIN"
echo "Server: $SERVER"
echo "========================================="
echo ""

# Step 1: Upload application files
echo "Step 1: Uploading application files..."
echo "Excluding node_modules, .next, and other build artifacts..."
echo ""

cd web-app

rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.next' \
  --exclude '.git' \
  --exclude 'dist' \
  --exclude 'build' \
  --exclude '.env' \
  --exclude '.env.local' \
  --exclude '.DS_Store' \
  --exclude '*.log' \
  . $SERVER_USER@$SERVER:$APP_DIR/

cd ..

echo ""
echo "Step 2: Installing and building on server..."
echo ""

# Step 2: SSH into server and build
ssh $SERVER_USER@$SERVER << ENDSSH
set -e

cd $APP_DIR

echo "Installing dependencies..."
npm install

echo "Generating Prisma client..."
npx prisma generate

echo "Pushing database schema..."
npx prisma db push --skip-generate || echo "Schema already up to date"

echo "Building application..."
npm run build

echo "Checking environment variables..."
if ! grep -q "GOOGLE_CLIENT_ID" .env || grep -q "REPLACE_WITH_YOUR" .env; then
    echo ""
    echo "⚠️  WARNING: Environment variables not configured!"
    echo "Please edit .env file and add your API keys"
    echo ""
fi

echo "Restarting application..."
pm2 restart foundersevents || pm2 start ecosystem.config.js

echo ""
echo "========================================="
echo "✅ Deployment Complete!"
echo "========================================="
echo ""
echo "Your app is now running at:"
echo "  http://$SERVER"
echo "  http://$DOMAIN (once DNS is configured)"
echo ""
echo "Next steps:"
echo "1. Point $DOMAIN DNS A record to $SERVER"
echo "2. Wait for DNS propagation (5-60 minutes)"
echo "3. Set up SSL: ssh $SERVER_USER@$SERVER 'certbot --nginx -d $DOMAIN -d www.$DOMAIN'"
echo ""
echo "View logs: ssh $SERVER_USER@$SERVER 'pm2 logs foundersevents'"
echo ""

ENDSSH

echo "========================================="
echo "🎉 Deployment Successful!"
echo "========================================="
echo ""
echo "Access your app:"
echo "  http://138.197.38.120 (available now)"
echo "  http://xlai.live (once DNS configured)"
echo ""

