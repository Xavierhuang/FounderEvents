# ScheduleShare Web App 🗓️✨

**Smart Calendar Management Powered by AI**

The web version of ScheduleShare brings all the powerful features from the iOS app to the browser, including AI-powered event extraction, NYC event discovery, LinkedIn networking, and intelligent route planning.

![ScheduleShare Demo](./public/demo-screenshot.png)

## 🚀 Features

### ✨ Core Features
- **AI Event Extraction**: Upload screenshots and let GPT-4 Vision extract event details automatically
- **Event Discovery**: Browse NYC tech events from Gary's Guide with real-time updates
- **Smart Networking**: Manage LinkedIn profiles from events with personalized messaging templates
- **Calendar Integration**: Seamless sync with Google Calendar (import/export)
- **Route Planning**: AI-optimized route planning for multi-event days in NYC
- **Easy Sharing**: Share events via email, ICS files, or direct links

### 🎯 Target Users
- **Tech Professionals** in NYC who attend multiple events
- **Event Organizers** who need to manage and share event information
- **Networkers** who want to track connections made at events
- **Busy Professionals** who need AI-powered calendar management

## 🛠️ Tech Stack

### Frontend
- **Next.js 14** with App Router
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Framer Motion** for animations
- **Radix UI** for accessible components
- **React Hook Form** for form management

### Backend
- **Next.js API Routes** (serverless functions)
- **PostgreSQL** with Prisma ORM
- **NextAuth.js** for authentication
- **OpenAI API** (GPT-4 Vision) for AI extraction
- **Google Calendar API** for calendar integration

### Deployment
- **Vercel** for hosting and serverless functions
- **Vercel Postgres** for database
- **Vercel Blob** for file storage

## 📦 Installation

### Prerequisites
- Node.js 18+ 
- PostgreSQL database
- OpenAI API key
- Google OAuth credentials

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/scheduleshare-web.git
cd scheduleshare-web
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Setup
```bash
cp env.example .env.local
```

Edit `.env.local` with your configuration:
```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/scheduleshare"

# NextAuth.js
NEXTAUTH_SECRET="your-secret-key-here"
NEXTAUTH_URL="http://localhost:3000"

# Google OAuth & Calendar API
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"

# OpenAI API
OPENAI_API_KEY="your-openai-api-key"
```

### 4. Database Setup
```bash
# Generate Prisma client
npm run db:generate

# Push schema to database
npm run db:push

# (Optional) Open Prisma Studio
npm run db:studio
```

### 5. Start Development Server
```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000) to see the app!

## 🔧 Configuration

### Google OAuth Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google Calendar API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - `http://localhost:3000/api/auth/callback/google` (development)
   - `https://yourdomain.com/api/auth/callback/google` (production)

### OpenAI API Setup
1. Get your API key from [OpenAI Platform](https://platform.openai.com/)
2. Ensure you have access to GPT-4 Vision (gpt-4-vision-preview)
3. Add the key to your environment variables

### Database Schema
The app uses PostgreSQL with the following main tables:
- `users` - User accounts and authentication
- `calendar_events` - User events with AI extraction data
- `linkedin_profiles` - LinkedIn contacts linked to events  
- `garys_guide_events` - Scraped NYC tech events
- `message_templates` - Customizable messaging templates
- `route_plans` - AI-generated route optimizations

## 🚀 Deployment

### Deploy to Vercel
1. Fork this repository
2. Connect your GitHub account to Vercel
3. Import the project
4. Set environment variables in Vercel dashboard
5. Deploy!

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/your-username/scheduleshare-web)

### Environment Variables for Production
```env
# Database (Vercel Postgres)
POSTGRES_URL="your-vercel-postgres-url"
POSTGRES_PRISMA_URL="your-vercel-postgres-prisma-url"
POSTGRES_URL_NON_POOLING="your-vercel-postgres-non-pooling-url"

# NextAuth.js
NEXTAUTH_SECRET="your-production-secret"
NEXTAUTH_URL="https://your-domain.com"

# APIs (same as development)
GOOGLE_CLIENT_ID="your-google-client-id"
GOOGLE_CLIENT_SECRET="your-google-client-secret"
OPENAI_API_KEY="your-openai-api-key"
```

## 📱 API Documentation

### Authentication
All API routes require authentication via NextAuth.js session.

### Events API
```typescript
// Get user events
GET /api/events?startDate=2024-01-01&endDate=2024-12-31&search=meetup

// Create new event
POST /api/events
{
  "title": "Tech Meetup",
  "startDate": "2024-12-15T18:00:00Z",
  "endDate": "2024-12-15T20:00:00Z",
  "location": "WeWork Union Square",
  "notes": "Networking event for tech professionals"
}
```

### AI Extraction API
```typescript
// Extract event from image
POST /api/ai/extract
{
  "imageData": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQ...",
  "prompt": "Extract event information from this screenshot"
}
```

### Discovery API
```typescript
// Get Gary's Guide events
GET /api/discover?eventType=popular&search=ai

// Refresh events (admin/cron)
POST /api/discover/refresh
```

## 🎨 UI Components

### Design System
The app uses a consistent design system with:
- **Primary Color**: Purple (#7c1aff)
- **Typography**: Inter font family
- **Spacing**: 8px grid system
- **Shadows**: Subtle elevation with blur
- **Animations**: Smooth transitions with Framer Motion

### Key Components
- `AppLayout` - Main application shell with navigation
- `EventCard` - Reusable event display component
- `CalendarGrid` - Interactive calendar view
- `ProfileCard` - LinkedIn profile management
- `RouteVisualization` - Route planning display

## 🧪 Testing

### Run Tests
```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Type checking
npm run type-check

# Linting
npm run lint
```

### Test Coverage
- Unit tests for utility functions
- Integration tests for API routes
- E2E tests for critical user flows
- Component testing with React Testing Library

## 📈 Performance

### Optimization Features
- **Next.js App Router** for optimal loading
- **Server Components** for reduced client bundle
- **Image Optimization** with Next.js Image component
- **API Route Caching** for external data
- **Database Indexing** for fast queries

### Monitoring
- **Vercel Analytics** for performance metrics
- **Error Tracking** with built-in error boundaries
- **Database Monitoring** via Prisma metrics

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style
- Use TypeScript for all new code
- Follow the existing ESLint configuration
- Use Prettier for code formatting
- Write meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** for GPT-4 Vision API
- **Gary's Guide** for NYC tech event data
- **Next.js Team** for the amazing framework
- **Vercel** for hosting and deployment
- **Tailwind CSS** for the utility-first CSS framework

## 📞 Support

- **Documentation**: [docs.scheduleshare.app](https://docs.scheduleshare.app)
- **Issues**: [GitHub Issues](https://github.com/your-username/scheduleshare-web/issues)
- **Email**: support@scheduleshare.app
- **Twitter**: [@ScheduleShare](https://twitter.com/ScheduleShare)

---

**Made with ❤️ for the NYC tech community**

[Visit ScheduleShare](https://scheduleshare.app) | [iOS App](https://apps.apple.com/app/scheduleshare) | [Documentation](https://docs.scheduleshare.app)
