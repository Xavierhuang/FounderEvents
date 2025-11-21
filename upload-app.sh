#!/bin/bash

# Upload Application Files to Server
# This script uploads only source code, excluding node_modules and build artifacts

SERVER="138.197.38.120"
SERVER_USER="root"
APP_DIR="/var/www/foundersevents"

echo "========================================="
echo "Uploading FoundersEvents to Server"
echo "========================================="
echo ""

# Check if web-app directory exists
if [ ! -d "web-app" ]; then
    echo "Error: web-app directory not found!"
    echo "Please run this script from the FoundersEvents root directory."
    exit 1
fi

echo "Uploading application files (excluding node_modules, .next, etc.)..."
echo "Server: $SERVER"
echo ""

# Use rsync to efficiently upload only necessary files
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
  web-app/ $SERVER_USER@$SERVER:$APP_DIR/

echo ""
echo "========================================="
echo "✅ Upload Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. SSH into server:"
echo "   ssh $SERVER_USER@$SERVER"
echo ""
echo "2. Install dependencies and build:"
echo "   cd $APP_DIR"
echo "   npm install"
echo "   npx prisma generate"
echo "   npm run build"
echo ""
echo "3. Start/restart the application:"
echo "   pm2 restart foundersevents"
echo ""
echo "4. View logs:"
echo "   pm2 logs foundersevents"
echo ""

