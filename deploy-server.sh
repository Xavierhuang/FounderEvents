#!/bin/bash

# FoundersEvents Server Setup Script
# Server: 138.197.38.120
# This script sets up a production-ready Next.js application with PostgreSQL

set -e

SERVER_IP="138.197.38.120"
APP_NAME="foundersevents"
DOMAIN="foundersevents.com"  # Update with your actual domain
NODE_VERSION="18"

echo "========================================="
echo "FoundersEvents Server Setup"
echo "========================================="
echo ""
echo "Server: $SERVER_IP"
echo "App: $APP_NAME"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}This script will:${NC}"
echo "1. Install Node.js, PostgreSQL, Nginx, PM2"
echo "2. Set up the database"
echo "3. Configure Nginx as reverse proxy"
echo "4. Deploy the Next.js application"
echo "5. Set up SSL with Let's Encrypt"
echo ""
echo -e "${YELLOW}Press Enter to continue or Ctrl+C to cancel${NC}"
read

# Upload this script to the server first
echo -e "${GREEN}Step 1: Uploading deployment files to server...${NC}"
scp -r ../FoundersEvents root@$SERVER_IP:/tmp/

echo -e "${GREEN}Step 2: Connecting to server and running setup...${NC}"

# Run the setup commands on the remote server
ssh root@$SERVER_IP << 'ENDSSH'

set -e

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Node.js 18.x
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install PostgreSQL
echo "Installing PostgreSQL..."
apt-get install -y postgresql postgresql-contrib

# Install Nginx
echo "Installing Nginx..."
apt-get install -y nginx

# Install PM2 globally
echo "Installing PM2..."
npm install -g pm2

# Install other dependencies
apt-get install -y git certbot python3-certbot-nginx

# Set up PostgreSQL
echo "Setting up PostgreSQL..."
sudo -u postgres psql << EOF
CREATE DATABASE foundersevents;
CREATE USER foundersevents WITH ENCRYPTED PASSWORD 'CHANGE_THIS_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE foundersevents TO foundersevents;
\q
EOF

# Create app directory
echo "Creating application directory..."
mkdir -p /var/www/foundersevents
cd /var/www/foundersevents

# Copy application files from /tmp
if [ -d "/tmp/FoundersEvents/web-app" ]; then
    echo "Copying application files..."
    cp -r /tmp/FoundersEvents/web-app/* .
    rm -rf /tmp/FoundersEvents
else
    echo "Warning: Application files not found in /tmp/FoundersEvents"
fi

# Create .env file
echo "Creating environment file..."
cat > .env << 'ENV'
# Database
DATABASE_URL="postgresql://foundersevents:CHANGE_THIS_PASSWORD@localhost:5432/foundersevents"

# NextAuth.js
NEXTAUTH_SECRET="CHANGE_THIS_SECRET_KEY"
NEXTAUTH_URL="http://138.197.38.120:3000"

# Google OAuth & Calendar API
GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID"
GOOGLE_CLIENT_SECRET="YOUR_GOOGLE_CLIENT_SECRET"

# OpenAI API
OPENAI_API_KEY="YOUR_OPENAI_API_KEY"

# Node Environment
NODE_ENV="production"
ENV

echo ""
echo "========================================="
echo "IMPORTANT: Edit /var/www/foundersevents/.env"
echo "Update all placeholder values!"
echo "========================================="
echo ""

# Install dependencies
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install --production=false
    
    # Generate Prisma client
    echo "Generating Prisma client..."
    npx prisma generate
    
    # Build the application
    echo "Building Next.js application..."
    npm run build
    
    # Push database schema
    echo "Setting up database schema..."
    npx prisma db push --skip-generate
else
    echo "Warning: package.json not found. Application setup incomplete."
fi

# Configure Nginx
echo "Configuring Nginx..."
cat > /etc/nginx/sites-available/foundersevents << 'NGINX'
server {
    listen 80;
    listen [::]:80;
    server_name 138.197.38.120;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

# Enable the site
ln -sf /etc/nginx/sites-available/foundersevents /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

# Set up PM2 to run the application
if [ -f "package.json" ]; then
    echo "Setting up PM2..."
    cd /var/www/foundersevents
    
    # Create PM2 ecosystem file
    cat > ecosystem.config.js << 'PM2'
module.exports = {
  apps: [{
    name: 'foundersevents',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/foundersevents',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
PM2
    
    # Start the application with PM2
    pm2 start ecosystem.config.js
    pm2 save
    pm2 startup systemd -u root --hp /root
fi

# Configure firewall
echo "Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo ""
echo "========================================="
echo "Server Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Edit /var/www/foundersevents/.env with your credentials"
echo "2. Restart the application: pm2 restart foundersevents"
echo "3. Access your app at: http://138.197.38.120"
echo ""
echo "Useful commands:"
echo "  pm2 status          - Check application status"
echo "  pm2 logs            - View application logs"
echo "  pm2 restart all     - Restart application"
echo "  nginx -t            - Test Nginx configuration"
echo "  systemctl status nginx - Check Nginx status"
echo ""

ENDSSH

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Your application should now be running at:"
echo "http://$SERVER_IP"
echo ""
echo -e "${YELLOW}IMPORTANT: You need to:${NC}"
echo "1. SSH into the server: ssh root@$SERVER_IP"
echo "2. Edit the .env file: nano /var/www/foundersevents/.env"
echo "3. Add your actual API keys and secrets"
echo "4. Restart the app: pm2 restart foundersevents"
echo ""

