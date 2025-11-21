#!/bin/bash

# Quick Deploy Script for FoundersEvents
# This script uploads the web app to your server at 138.197.38.120

SERVER="138.197.38.120"
SERVER_USER="root"
APP_DIR="/var/www/foundersevents"

echo "========================================="
echo "FoundersEvents Quick Deploy"
echo "========================================="
echo ""
echo "This will deploy your web app to $SERVER"
echo ""

# Check if web-app directory exists
if [ ! -d "web-app" ]; then
    echo "Error: web-app directory not found!"
    echo "Please run this script from the FoundersEvents root directory."
    exit 1
fi

echo "Step 1: Creating deployment package..."
cd web-app

# Create a temporary directory for deployment
TEMP_DIR=$(mktemp -d)
echo "Copying files to $TEMP_DIR..."

# Copy necessary files
cp -r . $TEMP_DIR/
cd $TEMP_DIR

# Remove node_modules and .next (we'll rebuild on server)
rm -rf node_modules .next

echo ""
echo "Step 2: Uploading files to server..."
echo "You will be prompted for the server password."
echo ""

# Upload to server (exclude large/unnecessary files)
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.next' \
  --exclude '.git' \
  --exclude 'dist' \
  --exclude 'build' \
  --exclude '.env.local' \
  --exclude '.DS_Store' \
  $TEMP_DIR/ $SERVER_USER@$SERVER:$APP_DIR/

echo ""
echo "Step 3: Installing dependencies and building on server..."
echo ""

# Run setup commands on server
ssh $SERVER_USER@$SERVER << 'ENDSSH'
cd /var/www/foundersevents

echo "Installing dependencies..."
npm install

echo "Generating Prisma client..."
npx prisma generate

echo "Building application..."
npm run build

echo "Pushing database schema..."
npx prisma db push --skip-generate || true

echo "Restarting application..."
pm2 restart foundersevents || pm2 start ecosystem.config.js

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="

ENDSSH

# Cleanup
rm -rf $TEMP_DIR

echo ""
echo "Your application has been deployed!"
echo "Visit: http://$SERVER"
echo ""
echo "To view logs: ssh $SERVER_USER@$SERVER 'pm2 logs foundersevents'"
echo ""

