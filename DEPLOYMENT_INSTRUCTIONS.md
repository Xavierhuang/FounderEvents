# Server Deployment Instructions

## Server Details
- **IP Address**: 138.197.38.120
- **Application**: FoundersEvents Web App
- **Stack**: Next.js 14, PostgreSQL, Nginx, PM2

## Quick Setup (Automated)

### Option 1: Run the deployment script

```bash
chmod +x deploy-server.sh
./deploy-server.sh
```

You'll be prompted for the root password when connecting to the server.

## Manual Setup (Step-by-Step)

If the automated script doesn't work, follow these manual steps:

### Step 1: Connect to Server

```bash
ssh root@138.197.38.120
```

### Step 2: Update System

```bash
apt-get update
apt-get upgrade -y
```

### Step 3: Install Node.js 18

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
node --version  # Should show v18.x
```

### Step 4: Install PostgreSQL

```bash
apt-get install -y postgresql postgresql-contrib
systemctl start postgresql
systemctl enable postgresql
```

### Step 5: Set Up Database

```bash
sudo -u postgres psql
```

In PostgreSQL console:

```sql
CREATE DATABASE foundersevents;
CREATE USER foundersevents WITH ENCRYPTED PASSWORD 'your_secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE foundersevents TO foundersevents;
ALTER DATABASE foundersevents OWNER TO foundersevents;
\q
```

### Step 6: Install Nginx

```bash
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
```

### Step 7: Install PM2

```bash
npm install -g pm2
```

### Step 8: Install Additional Tools

```bash
apt-get install -y git certbot python3-certbot-nginx
```

### Step 9: Create Application Directory

```bash
mkdir -p /var/www/foundersevents
cd /var/www/foundersevents
```

### Step 10: Upload Application Files

From your local machine (new terminal):

```bash
cd /Users/weijiahuang/Desktop/FoundersEvents
scp -r web-app/* root@138.197.38.120:/var/www/foundersevents/
```

### Step 11: Create Environment File

On the server:

```bash
cd /var/www/foundersevents
nano .env
```

Add the following content (update with your actual values):

```env
# Database
DATABASE_URL="postgresql://foundersevents:your_secure_password_here@localhost:5432/foundersevents"

# NextAuth.js (Generate a secure secret: openssl rand -base64 32)
NEXTAUTH_SECRET="your_generated_secret_key_here"
NEXTAUTH_URL="http://138.197.38.120"

# Google OAuth & Calendar API
GOOGLE_CLIENT_ID="your_google_client_id"
GOOGLE_CLIENT_SECRET="your_google_client_secret"

# OpenAI API
OPENAI_API_KEY="your_openai_api_key"

# Node Environment
NODE_ENV="production"
PORT=3000
```

Save and exit (Ctrl+O, Enter, Ctrl+X)

### Step 12: Install Dependencies and Build

```bash
cd /var/www/foundersevents
npm install
npx prisma generate
npm run build
```

### Step 13: Set Up Database Schema

```bash
npx prisma db push
```

### Step 14: Configure Nginx

```bash
nano /etc/nginx/sites-available/foundersevents
```

Add the following configuration:

```nginx
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
}
```

Enable the site:

```bash
ln -s /etc/nginx/sites-available/foundersevents /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
```

### Step 15: Create PM2 Ecosystem File

```bash
cd /var/www/foundersevents
nano ecosystem.config.js
```

Add:

```javascript
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
```

### Step 16: Start Application with PM2

```bash
cd /var/www/foundersevents
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd
```

Copy and run the command that PM2 outputs.

### Step 17: Configure Firewall

```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
ufw status
```

### Step 18: Test the Application

Open your browser and navigate to:
```
http://138.197.38.120
```

## Post-Deployment Configuration

### Set Up Domain (Optional)

If you have a domain name:

1. Point your domain's A record to `138.197.38.120`

2. Update Nginx configuration:
```bash
nano /etc/nginx/sites-available/foundersevents
```

Change `server_name 138.197.38.120;` to `server_name yourdomain.com www.yourdomain.com;`

3. Update `.env`:
```bash
nano /var/www/foundersevents/.env
```

Change `NEXTAUTH_URL` to `https://yourdomain.com`

4. Set up SSL with Let's Encrypt:
```bash
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### Update Google OAuth

Add to Google Cloud Console:
- Authorized JavaScript origins: `http://138.197.38.120` (or your domain)
- Authorized redirect URIs: `http://138.197.38.120/api/auth/callback/google`

## Useful Commands

### Application Management

```bash
# View application status
pm2 status

# View logs
pm2 logs foundersevents

# View real-time logs
pm2 logs foundersevents --lines 100

# Restart application
pm2 restart foundersevents

# Stop application
pm2 stop foundersevents

# Reload application (zero-downtime)
pm2 reload foundersevents
```

### Database Management

```bash
# Connect to PostgreSQL
sudo -u postgres psql foundersevents

# Backup database
pg_dump -U foundersevents foundersevents > backup.sql

# Restore database
psql -U foundersevents foundersevents < backup.sql
```

### Nginx Management

```bash
# Test configuration
nginx -t

# Restart Nginx
systemctl restart nginx

# View Nginx status
systemctl status nginx

# View Nginx logs
tail -f /var/log/nginx/error.log
```

### System Monitoring

```bash
# Check disk space
df -h

# Check memory usage
free -m

# Check CPU usage
top

# Check running processes
ps aux | grep node
```

## Updating the Application

When you make changes to your code:

```bash
# On your local machine
cd /Users/weijiahuang/Desktop/FoundersEvents
scp -r web-app/* root@138.197.38.120:/var/www/foundersevents/

# On the server
cd /var/www/foundersevents
npm install
npx prisma generate
npx prisma db push  # If schema changed
npm run build
pm2 restart foundersevents
```

## Troubleshooting

### Application won't start

```bash
# Check logs
pm2 logs foundersevents --err

# Check if port 3000 is available
lsof -i :3000

# Manually start to see errors
cd /var/www/foundersevents
npm start
```

### Database connection issues

```bash
# Check PostgreSQL is running
systemctl status postgresql

# Test database connection
psql -U foundersevents -d foundersevents -h localhost

# Check .env file
cat /var/www/foundersevents/.env
```

### Nginx issues

```bash
# Check Nginx configuration
nginx -t

# View error logs
tail -f /var/log/nginx/error.log

# Check if Nginx is running
systemctl status nginx
```

### Out of memory

```bash
# Check memory usage
free -m

# Restart application
pm2 restart foundersevents

# Consider upgrading server or optimizing code
```

## Security Best Practices

1. **Change default PostgreSQL password immediately**
2. **Use strong NEXTAUTH_SECRET** (generate with: `openssl rand -base64 32`)
3. **Keep system updated**: `apt-get update && apt-get upgrade`
4. **Monitor logs regularly**: `pm2 logs`
5. **Set up automated backups** for database
6. **Use SSL/HTTPS** in production (Let's Encrypt)
7. **Restrict SSH access** (consider key-based auth only)
8. **Monitor API usage** (OpenAI, Google)

## Backup Strategy

### Database Backup Script

Create `/root/backup-db.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/root/backups"
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U foundersevents foundersevents > $BACKUP_DIR/foundersevents_$DATE.sql
# Keep only last 7 days
find $BACKUP_DIR -name "foundersevents_*.sql" -mtime +7 -delete
```

Make executable and add to crontab:
```bash
chmod +x /root/backup-db.sh
crontab -e
```

Add line:
```
0 2 * * * /root/backup-db.sh
```

## Support

For issues:
1. Check application logs: `pm2 logs foundersevents`
2. Check Nginx logs: `tail -f /var/log/nginx/error.log`
3. Check system resources: `htop` or `top`
4. Review this documentation

---

**Server Setup Checklist:**

- [ ] Server accessed via SSH
- [ ] System updated
- [ ] Node.js 18 installed
- [ ] PostgreSQL installed and configured
- [ ] Database created
- [ ] Nginx installed and configured
- [ ] PM2 installed
- [ ] Application files uploaded
- [ ] .env file created with correct values
- [ ] Dependencies installed
- [ ] Database schema pushed
- [ ] Application built successfully
- [ ] PM2 configured and running
- [ ] Firewall configured
- [ ] Application accessible via browser
- [ ] Google OAuth configured
- [ ] SSL certificate installed (optional)
- [ ] Backups configured
- [ ] Monitoring set up

**Your application is now live!**

