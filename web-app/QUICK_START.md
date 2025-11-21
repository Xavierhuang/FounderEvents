# ScheduleShare Web - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Install Dependencies
```bash
cd web-app
npm install
```

### Step 2: Set Up Environment Variables
Copy the example file and fill in your credentials:
```bash
cp env.example .env.local
```

Required variables:
- `DATABASE_URL` - PostgreSQL connection string
- `NEXTAUTH_SECRET` - Random 32+ character string
- `GOOGLE_CLIENT_ID` - From Google Cloud Console
- `GOOGLE_CLIENT_SECRET` - From Google Cloud Console
- `OPENAI_API_KEY` - From OpenAI Platform

### Step 3: Set Up Database
```bash
npm run db:generate
npm run db:push
```

### Step 4: Start Development Server
```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

## 🎯 Test the Features

### 1. Authentication
- Click "Sign in with Google"
- Authenticate with your Google account
- You'll be redirected to the dashboard

### 2. Create an Event (AI)
- Go to "Add Event"
- Select "AI Extraction"
- Upload a screenshot of an event
- Watch AI extract the details
- Review and save

### 3. Create an Event (Manual)
- Go to "Add Event"
- Select "Manual Entry"
- Fill in the form
- Save

### 4. Discover Events
- Go to "Discover"
- Browse NYC tech events
- Filter by type (popular, free, paid)
- Search events
- Click "Add to Calendar"

### 5. View Calendar
- Go to "Calendar"
- See your events in month view
- Click on dates to see events
- Click on events for details

### 6. Add LinkedIn Connection
- Go to "Connections"
- Click "Add Connection"
- Fill in profile details
- Link to an event (optional)
- Save

### 7. Plan a Route
- Go to "Route Planning"
- Select multiple events
- Click "Generate Route"
- View AI-optimized route with costs

### 8. Configure Settings
- Go to "Settings"
- Set timezone and preferences
- Configure Google Calendar sync
- Add message templates

## 📁 Project Structure

```
web-app/
├── app/                      # Next.js App Router
│   ├── api/                  # API Routes
│   ├── dashboard/            # Protected pages
│   ├── auth/                 # Auth pages
│   └── page.tsx             # Landing page
├── src/
│   ├── components/          # React components
│   ├── lib/                 # Utilities
│   └── types/               # TypeScript types
├── prisma/                  # Database schema
└── public/                  # Static assets
```

## 🛠️ Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Check TypeScript types
- `npm run db:generate` - Generate Prisma client
- `npm run db:push` - Push schema to database
- `npm run db:studio` - Open Prisma Studio

## 🔑 Getting API Keys

### Google OAuth (Required)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable Google Calendar API
4. Create OAuth 2.0 credentials
5. Add redirect URI: `http://localhost:3000/api/auth/callback/google`
6. Copy Client ID and Secret

### OpenAI (Required for AI features)
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an account
3. Add payment method
4. Generate API key
5. Copy the key

### Database (Required)
**Local Development:**
```bash
# Install PostgreSQL
brew install postgresql  # macOS
# or use Docker:
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=password postgres
```

**Or use Vercel Postgres (recommended for deployment):**
1. Create a Vercel account
2. Add Postgres storage
3. Copy connection string

## ⚠️ Common Issues

### "Database connection failed"
- Check your DATABASE_URL
- Ensure PostgreSQL is running
- Run `npm run db:push`

### "Google OAuth error"
- Verify redirect URI is correct
- Check credentials are not expired
- Enable Google Calendar API

### "OpenAI API error"
- Verify API key is valid
- Check you have credits
- Ensure GPT-4 Vision access

### Build errors
- Delete `.next` folder
- Run `npm install` again
- Check TypeScript errors with `npm run type-check`

## 📚 Documentation

- `README.md` - Project overview
- `ARCHITECTURE.md` - System architecture
- `IMPLEMENTATION_SUMMARY.md` - Feature list
- `README_DEPLOYMENT.md` - Deployment guide

## 🎉 You're Ready!

The app is now running and fully functional. Explore all the features:

✅ AI event extraction  
✅ Event discovery  
✅ Calendar management  
✅ LinkedIn networking  
✅ Route planning  
✅ Google Calendar sync  
✅ Event sharing  

Need help? Check the documentation or reach out for support!

---

**Happy Scheduling! 📅**

