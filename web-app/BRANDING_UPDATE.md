# Branding Update: ScheduleShare → FoundersEvents

## Database Name
- Old: `scheduleshare`
- New: `foundersevents`

## Create MySQL Database:
```bash
mysql -u root -p
CREATE DATABASE foundersevents;
EXIT;
```

## Update .env.local:
```env
# Local MySQL
DATABASE_URL="mysql://root:password@localhost:3306/foundersevents"

# Or PlanetScale
DATABASE_URL="mysql://user:pass@aws.connect.psdb.cloud/foundersevents?sslaccept=strict"
```

## Brand Names Throughout App:
- App Name: **FoundersEvents**
- Description: Event Platform for Founders & Entrepreneurs
- Domain suggestions: 
  - foundersevents.com
  - foundersevents.app
  - founderevents.io

All references have been updated in the codebase!
