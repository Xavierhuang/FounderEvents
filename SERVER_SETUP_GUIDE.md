# Server Setup Guide - Quick Start

## 🚀 Deploy to 138.197.38.120

This guide will help you set up your FoundersEvents web application on your server.

## Prerequisites

- SSH access to server: `ssh root@138.197.38.120`
- Server running Ubuntu 20.04+ or Debian 10+
- Root or sudo access

## Quick Setup (Recommended)

### Step 1: Run Initial Server Setup

From your local machine:

```bash
cd /Users/weijiahuang/Desktop/FoundersEvents
ssh root@138.197.38.120 'bash -s' < deploy-server.sh
```

Enter your password when prompted. This will:
- Install Node.js, PostgreSQL, Nginx, PM2
- Set up the database
- Configure Nginx reverse proxy
- Deploy your application

**Note:** The automated script will prompt you to update environment variables after installation.

### Step 2: Configure Environment Variables

After the script completes, SSH into your server:

```bash
ssh root@138.197.38.120
```

Edit the environment file:

```bash
nano /var/www/foundersevents/.env
```

Update these critical values:

1. **Database Password**: Change `CHANGE_THIS_PASSWORD` to a secure password
2. **NextAuth Secret**: Generate with `openssl rand -base64 32`
3. **Google OAuth**: Add your Google Client ID and Secret
4. **OpenAI API Key**: Add your OpenAI API key

Save and exit (Ctrl+O, Enter, Ctrl+X)

### Step 3: Restart Application

```bash
pm2 restart foundersevents
```

### Step 4: Access Your App

Open your browser: **http://138.197.38.120**

## Manual Setup (If Automated Script Fails)

Follow the detailed instructions in `DEPLOYMENT_INSTRUCTIONS.md`

## For Future Updates

Use the quick deploy script:

```bash
cd /Users/weijiahuang/Desktop/FoundersEvents
./quick-deploy.sh
```

This will:
- Upload your latest code
- Install dependencies
- Rebuild the application
- Restart the service

## Getting Your API Keys

### Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Calendar API
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Add authorized redirect URI: `http://138.197.38.120/api/auth/callback/google`
6. Copy Client ID and Client Secret

### OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create account
3. Click "Create new secret key"
4. Copy the key (you won't see it again!)

## Useful Commands

### Check Application Status

```bash
ssh root@138.197.38.120
pm2 status
```

### View Logs

```bash
ssh root@138.197.38.120
pm2 logs foundersevents
```

### Restart Application

```bash
ssh root@138.197.38.120
pm2 restart foundersevents
```

### Check Database

```bash
ssh root@138.197.38.120
sudo -u postgres psql foundersevents
```

## Troubleshooting

### Application Not Starting

```bash
ssh root@138.197.38.120
pm2 logs foundersevents --err
```

Look for errors related to:
- Missing environment variables
- Database connection issues
- Port conflicts

### Can't Access from Browser

Check if Nginx is running:

```bash
ssh root@138.197.38.120
systemctl status nginx
```

Check if app is running:

```bash
ssh root@138.197.38.120
pm2 status
curl http://localhost:3000
```

### Database Connection Errors

1. Verify PostgreSQL is running:
```bash
ssh root@138.197.38.120
systemctl status postgresql
```

2. Check .env file has correct DATABASE_URL:
```bash
ssh root@138.197.38.120
cat /var/www/foundersevents/.env | grep DATABASE_URL
```

3. Test database connection:
```bash
ssh root@138.197.38.120
sudo -u postgres psql -c "\l" | grep foundersevents
```

## Security Recommendations

1. **Change default passwords immediately**
2. **Use strong NEXTAUTH_SECRET** (32+ characters)
3. **Set up SSL with Let's Encrypt** (if you have a domain)
4. **Regular backups** of database
5. **Monitor logs** for unusual activity
6. **Keep system updated**: `apt-get update && apt-get upgrade`

## Setting Up SSL (With Domain)

If you have a domain pointing to your server:

```bash
ssh root@138.197.38.120

# Install certbot
apt-get install certbot python3-certbot-nginx

# Get certificate
certbot --nginx -d yourdomain.com

# Update .env
nano /var/www/foundersevents/.env
# Change NEXTAUTH_URL to https://yourdomain.com

# Restart app
pm2 restart foundersevents
```

## Backup Your Database

Create a backup:

```bash
ssh root@138.197.38.120
pg_dump -U foundersevents foundersevents > /root/backup-$(date +%Y%m%d).sql
```

Download backup to local machine:

```bash
scp root@138.197.38.120:/root/backup-*.sql ~/Desktop/
```

## Monitoring

### Resource Usage

```bash
ssh root@138.197.38.120
htop  # or 'top'
df -h  # disk space
free -m  # memory
```

### Application Metrics

```bash
ssh root@138.197.38.120
pm2 monit  # Real-time monitoring
```

## Next Steps

1. ✅ Deploy application
2. ✅ Configure environment variables
3. ✅ Set up Google OAuth
4. ✅ Add OpenAI API key
5. ✅ Test authentication
6. ✅ Create your first event
7. ⬜ Set up domain (optional)
8. ⬜ Configure SSL (optional)
9. ⬜ Set up automated backups
10. ⬜ Configure monitoring alerts

## Support

For detailed step-by-step instructions, see:
- `DEPLOYMENT_INSTRUCTIONS.md` - Complete manual setup guide
- `web-app/README_DEPLOYMENT.md` - Web app specific deployment info

## Quick Reference

| Command | Description |
|---------|-------------|
| `./deploy-server.sh` | Initial server setup |
| `./quick-deploy.sh` | Deploy code updates |
| `ssh root@138.197.38.120` | Connect to server |
| `pm2 status` | Check app status |
| `pm2 logs` | View app logs |
| `pm2 restart foundersevents` | Restart app |
| `nginx -t` | Test Nginx config |
| `systemctl status nginx` | Check Nginx status |

---

**Ready to deploy? Run:**

```bash
cd /Users/weijiahuang/Desktop/FoundersEvents
./deploy-server.sh
```

Then follow the prompts!

