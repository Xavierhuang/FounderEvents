# MySQL Setup Guide for ScheduleShare

## Quick Setup Options

### Option 1: PlanetScale (Recommended - Free & Easy)

**Best for production, no local installation needed**

1. **Go to:** https://planetscale.com
2. **Sign up** (free tier available)
3. **Create database:**
   - Click "New Database"
   - Name: `scheduleshare`
   - Region: Choose closest to you
4. **Get connection string:**
   - Click "Connect"
   - Select "Prisma"
   - Copy the connection string
5. **Update `.env.local`:**
   ```env
   DATABASE_URL="mysql://user:pass@aws.connect.psdb.cloud/scheduleshare?sslaccept=strict"
   ```
6. **Run migrations:**
   ```bash
   npm run db:push
   ```

**Pros:**
- ✅ Free tier (5GB storage)
- ✅ No installation needed
- ✅ Automatic backups
- ✅ Global edge network
- ✅ Easy branching

---

### Option 2: Local MySQL Installation

#### macOS (using Homebrew)
```bash
# Install MySQL
brew install mysql

# Start MySQL service
brew services start mysql

# Secure installation (optional but recommended)
mysql_secure_installation

# Login to MySQL
mysql -u root -p

# Create database
CREATE DATABASE scheduleshare;
CREATE USER 'scheduleshare_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON scheduleshare.* TO 'scheduleshare_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Update `.env.local`:**
```env
DATABASE_URL="mysql://scheduleshare_user:your_password@localhost:3306/scheduleshare"
```

#### Windows
1. Download MySQL from: https://dev.mysql.com/downloads/mysql/
2. Install MySQL Server
3. Use MySQL Workbench or command line to create database:
```sql
CREATE DATABASE scheduleshare;
```

**Update `.env.local`:**
```env
DATABASE_URL="mysql://root:your_password@localhost:3306/scheduleshare"
```

---

### Option 3: Docker (Cross-platform)

```bash
# Run MySQL in Docker
docker run --name mysql-scheduleshare \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=scheduleshare \
  -p 3306:3306 \
  -d mysql:8.0

# Check if running
docker ps
```

**Update `.env.local`:**
```env
DATABASE_URL="mysql://root:password@localhost:3306/scheduleshare"
```

**To stop/start:**
```bash
docker stop mysql-scheduleshare
docker start mysql-scheduleshare
```

---

### Option 4: Free Cloud MySQL Services

#### Railway
1. Go to: https://railway.app
2. Create new project → Add MySQL
3. Copy connection string from variables
4. Update `.env.local`

#### Aiven
1. Go to: https://aiven.io
2. Create free MySQL service
3. Get connection details
4. Update `.env.local`

---

## After Setting Up Database

1. **Generate Prisma Client:**
   ```bash
   cd web-app
   npm run db:generate
   ```

2. **Push Schema to Database:**
   ```bash
   npm run db:push
   ```

3. **Start Development Server:**
   ```bash
   npm run dev
   ```

4. **Verify Connection:**
   - Check terminal for successful connection
   - Try signing in at http://localhost:3001
   - Create a test event

---

## Troubleshooting

### Error: Access denied for user
```bash
# Reset MySQL root password (macOS)
mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

### Error: Can't connect to MySQL server
```bash
# Check if MySQL is running
brew services list  # macOS
# or
systemctl status mysql  # Linux
# or
docker ps  # Docker
```

### Error: Database doesn't exist
```bash
mysql -u root -p
CREATE DATABASE scheduleshare;
```

### Error: relationMode warning
This is normal with PlanetScale and some cloud MySQL providers. Keep `relationMode = "prisma"` in schema.

---

## Production Recommendations

### Best Options:
1. **PlanetScale** - Best for serverless, automatic scaling
2. **AWS RDS MySQL** - Best for full control
3. **Digital Ocean Managed MySQL** - Good balance of price/features
4. **Railway** - Easy deployment

### Configuration for Production:
```env
# Use connection pooling
DATABASE_URL="mysql://user:pass@host:3306/db?connection_limit=10"

# Enable SSL
DATABASE_URL="mysql://user:pass@host:3306/db?sslaccept=strict"
```

---

## Database Management Tools

### GUI Tools:
- **MySQL Workbench** (Official, Free)
- **TablePlus** (macOS, Paid but good)
- **DBeaver** (Free, Cross-platform)
- **phpMyAdmin** (Web-based)

### Access Prisma Studio:
```bash
npm run db:studio
```
Opens web interface at http://localhost:5555

---

## Quick Commands Reference

```bash
# Check MySQL version
mysql --version

# Login to MySQL
mysql -u root -p

# Show databases
SHOW DATABASES;

# Use database
USE scheduleshare;

# Show tables
SHOW TABLES;

# Check table structure
DESCRIBE users;

# Backup database
mysqldump -u root -p scheduleshare > backup.sql

# Restore database
mysql -u root -p scheduleshare < backup.sql
```

---

## Next Steps

1. ✅ Choose your MySQL option (PlanetScale recommended)
2. ✅ Update `.env.local` with connection string
3. ✅ Run `npm run db:push`
4. ✅ Start creating events!

---

**Questions or issues?** Check the troubleshooting section or refer to:
- Prisma MySQL docs: https://www.prisma.io/docs/concepts/database-connectors/mysql
- PlanetScale docs: https://planetscale.com/docs

