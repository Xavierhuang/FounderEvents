#!/bin/bash

# FoundersEvents Server Setup Script (Remote Execution)
# This script runs directly on the server

set -e

echo "========================================="
echo "FoundersEvents Server Setup"
echo "Starting setup on $(hostname)..."
echo "========================================="

# Update system
echo "Step 1: Updating system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Node.js 18.x
echo "Step 2: Installing Node.js 18..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"

# Install PostgreSQL
echo "Step 3: Installing PostgreSQL..."
if ! command -v psql &> /dev/null; then
    apt-get install -y postgresql postgresql-contrib
    systemctl start postgresql
    systemctl enable postgresql
fi
echo "PostgreSQL installed"

# Install Nginx
echo "Step 4: Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
fi
echo "Nginx installed"

# Install PM2 globally
echo "Step 5: Installing PM2..."
npm install -g pm2

# Install other tools
echo "Step 6: Installing additional tools..."
apt-get install -y git certbot python3-certbot-nginx

# Set up PostgreSQL database
echo "Step 7: Setting up PostgreSQL database..."
DB_PASSWORD=$(openssl rand -base64 16 | tr -d '/+=' | head -c 20)
sudo -u postgres psql << EOF
-- Drop database if exists (for clean setup)
DROP DATABASE IF EXISTS foundersevents;
DROP USER IF EXISTS foundersevents;

-- Create fresh database and user
CREATE DATABASE foundersevents;
CREATE USER foundersevents WITH ENCRYPTED PASSWORD '$DB_PASSWORD';
ALTER DATABASE foundersevents OWNER TO foundersevents;
GRANT ALL PRIVILEGES ON DATABASE foundersevents TO foundersevents;
\q
EOF
echo "Database created with user: foundersevents"

# Create app directory
echo "Step 8: Creating application directory..."
mkdir -p /var/www/foundersevents
cd /var/www/foundersevents

# Generate NextAuth secret
echo "Step 9: Generating secrets..."
NEXTAUTH_SECRET=$(openssl rand -base64 32)

# Create .env file
echo "Step 10: Creating environment file..."
cat > .env << ENV
# Database
DATABASE_URL="postgresql://foundersevents:${DB_PASSWORD}@localhost:5432/foundersevents"

# NextAuth.js
NEXTAUTH_SECRET="${NEXTAUTH_SECRET}"
NEXTAUTH_URL="http://138.197.38.120"

# Google OAuth & Calendar API
GOOGLE_CLIENT_ID="REPLACE_WITH_YOUR_GOOGLE_CLIENT_ID"
GOOGLE_CLIENT_SECRET="REPLACE_WITH_YOUR_GOOGLE_CLIENT_SECRET"

# OpenAI API
OPENAI_API_KEY="REPLACE_WITH_YOUR_OPENAI_API_KEY"

# Node Environment
NODE_ENV="production"
PORT=3000
ENV

chmod 600 .env

# Save credentials for reference
cat > /root/foundersevents-credentials.txt << CREDS
FoundersEvents Database Credentials
====================================
Database: foundersevents
Username: foundersevents
Password: ${DB_PASSWORD}

NextAuth Secret: ${NEXTAUTH_SECRET}

IMPORTANT: Update .env file at /var/www/foundersevents/.env
Add your Google OAuth and OpenAI API keys!

To edit: nano /var/www/foundersevents/.env
CREDS

chmod 600 /root/foundersevents-credentials.txt

echo "Credentials saved to: /root/foundersevents-credentials.txt"

# Create placeholder package.json if app files aren't uploaded yet
if [ ! -f "package.json" ]; then
    echo "Step 11: Creating placeholder for application..."
    echo "Application files should be uploaded separately"
else
    echo "Step 11: Installing application dependencies..."
    npm install
    
    if [ -f "prisma/schema.prisma" ]; then
        echo "Generating Prisma client..."
        npx prisma generate
        
        echo "Setting up database schema..."
        npx prisma db push --skip-generate
    fi
    
    echo "Building application..."
    npm run build
fi

# Configure Nginx
echo "Step 12: Configuring Nginx..."
cat > /etc/nginx/sites-available/foundersevents << 'NGINX'
server {
    listen 80;
    listen [::]:80;
    server_name 138.197.38.120;

    client_max_body_size 10M;

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
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
NGINX

# Enable site
ln -sf /etc/nginx/sites-available/foundersevents /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
nginx -t
systemctl restart nginx

# Create PM2 ecosystem file
echo "Step 13: Creating PM2 configuration..."
cat > /var/www/foundersevents/ecosystem.config.js << 'PM2'
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
    },
    error_file: '/var/log/foundersevents-error.log',
    out_file: '/var/log/foundersevents-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
PM2

# Start with PM2 only if package.json exists
if [ -f "/var/www/foundersevents/package.json" ]; then
    echo "Step 14: Starting application with PM2..."
    cd /var/www/foundersevents
    pm2 start ecosystem.config.js
    pm2 save
    pm2 startup systemd -u root --hp /root | tail -n 1 | bash
else
    echo "Step 14: Skipping PM2 start (no application files yet)"
fi

# Configure firewall
echo "Step 15: Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable

echo ""
echo "========================================="
echo "✅ Server Setup Complete!"
echo "========================================="
echo ""
echo "📋 Summary:"
echo "  - Node.js $(node --version) installed"
echo "  - PostgreSQL installed and configured"
echo "  - Nginx configured as reverse proxy"
echo "  - PM2 process manager installed"
echo "  - Firewall configured"
echo ""
echo "🔑 Database Credentials:"
echo "  Database: foundersevents"
echo "  Username: foundersevents"
echo "  Password: $DB_PASSWORD"
echo ""
echo "📝 Credentials saved to: /root/foundersevents-credentials.txt"
echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo ""
echo "1. Upload your application files:"
echo "   scp -r web-app/* root@138.197.38.120:/var/www/foundersevents/"
echo ""
echo "2. Edit the .env file and add your API keys:"
echo "   ssh root@138.197.38.120"
echo "   nano /var/www/foundersevents/.env"
echo ""
echo "   You need to add:"
echo "   - GOOGLE_CLIENT_ID"
echo "   - GOOGLE_CLIENT_SECRET"
echo "   - OPENAI_API_KEY"
echo ""
echo "3. After uploading files and updating .env:"
echo "   cd /var/www/foundersevents"
echo "   npm install"
echo "   npx prisma generate"
echo "   npx prisma db push"
echo "   npm run build"
echo "   pm2 start ecosystem.config.js"
echo ""
echo "4. Access your app at: http://138.197.38.120"
echo ""
echo "📊 Useful commands:"
echo "   pm2 status              - Check app status"
echo "   pm2 logs foundersevents - View logs"
echo "   pm2 restart all         - Restart app"
echo ""
echo "========================================="

