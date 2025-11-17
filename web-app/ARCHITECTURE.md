# ScheduleShare Web App Architecture

## 🏗️ System Overview

ScheduleShare Web is a comprehensive calendar management platform that replicates and enhances all features from the iOS app. Built with modern web technologies, it provides a seamless experience for event management, AI-powered extraction, and professional networking.

## 📊 Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   External      │
│   (Next.js)     │    │   (API Routes)  │    │   Services      │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • React 18      │◄──►│ • Next.js 14    │◄──►│ • OpenAI API    │
│ • TypeScript    │    │ • Prisma ORM    │    │ • Google Cal    │
│ • Tailwind CSS  │    │ • NextAuth.js   │    │ • Gary's Guide  │
│ • Framer Motion │    │ • PostgreSQL    │    │ • LinkedIn API  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 Core Features Implemented

### 1. **Authentication & User Management**
- **NextAuth.js** with Google OAuth
- Session-based authentication
- User preferences and settings
- Secure API route protection

### 2. **AI-Powered Event Extraction**
- **GPT-4 Vision** integration for screenshot analysis
- Automatic event detail extraction (title, date, time, location)
- High confidence scoring and validation
- Support for multiple image formats

### 3. **Event Management**
- Full CRUD operations for calendar events
- Advanced filtering and search
- Event linking with LinkedIn profiles
- Calendar import/export (ICS format)

### 4. **Event Discovery**
- Gary's Guide NYC tech events integration
- Real-time event scraping and updates
- Event categorization (Popular, Free, Paid)
- Advanced search and filtering

### 5. **LinkedIn Integration**
- Profile management and linking to events
- Customizable message templates
- Networking contact organization
- Event-based connection tracking

### 6. **Smart Route Planning** (Framework Ready)
- AI-powered route optimization
- Multi-event day planning
- Transportation mode selection
- Cost and time optimization

## 🗂️ Project Structure

```
scheduleshare-web/
├── app/                          # Next.js App Router
│   ├── api/                      # API Routes
│   │   ├── auth/                 # NextAuth endpoints
│   │   ├── events/               # Event CRUD operations
│   │   ├── ai/                   # AI extraction endpoints
│   │   ├── discover/             # Gary's Guide integration
│   │   └── linkedin/             # LinkedIn profile management
│   ├── dashboard/                # Protected dashboard pages
│   │   ├── calendar/             # Calendar view
│   │   ├── discover/             # Event discovery
│   │   ├── connections/          # LinkedIn profiles
│   │   └── settings/             # User settings
│   ├── auth/                     # Authentication pages
│   └── layout.tsx                # Root layout
├── src/
│   ├── components/               # React components
│   │   ├── layout/               # Layout components
│   │   ├── dashboard/            # Dashboard widgets
│   │   ├── events/               # Event-related components
│   │   ├── calendar/             # Calendar components
│   │   └── ui/                   # Reusable UI components
│   ├── lib/                      # Utility libraries
│   │   ├── prisma.ts             # Database client
│   │   ├── auth.ts               # NextAuth configuration
│   │   └── utils.ts              # Helper functions
│   └── types/                    # TypeScript type definitions
├── prisma/                       # Database schema and migrations
├── public/                       # Static assets
└── scripts/                      # Setup and deployment scripts
```

## 🗄️ Database Schema

### Core Tables

#### **Users**
```sql
users {
  id: String (PK)
  email: String (unique)
  name: String?
  image: String?
  emailVerified: DateTime?
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### **Calendar Events**
```sql
calendar_events {
  id: String (PK)
  title: String
  startDate: DateTime
  endDate: DateTime
  location: String?
  notes: Text?
  eventIdentifier: String?        # Google Calendar ID
  extractedInfo: JSON?            # AI extraction data
  userId: String (FK)
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### **LinkedIn Profiles**
```sql
linkedin_profiles {
  id: String (PK)
  profileURL: String
  name: String
  company: String?
  title: String?
  notes: Text?
  linkedDate: DateTime
  userId: String (FK)
  linkedEventId: String? (FK)
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### **Gary's Guide Events**
```sql
garys_guide_events {
  id: String (PK)
  title: String
  date: String
  time: String
  price: String
  venue: String
  speakers: Text
  url: String
  isGaryEvent: Boolean
  isPopularEvent: Boolean
  week: String
  scrapedAt: DateTime
  isActive: Boolean
}
```

## 🔌 API Design

### RESTful Endpoints

#### **Authentication**
- `GET/POST /api/auth/*` - NextAuth.js endpoints

#### **Events**
- `GET /api/events` - List user events with filtering
- `POST /api/events` - Create new event
- `GET /api/events/[id]` - Get specific event
- `PUT /api/events/[id]` - Update event
- `DELETE /api/events/[id]` - Delete event

#### **AI Extraction**
- `POST /api/ai/extract` - Extract event from image
- `POST /api/ai/optimize-route` - Generate route plan

#### **Discovery**
- `GET /api/discover` - List Gary's Guide events
- `POST /api/discover/refresh` - Refresh event data

#### **LinkedIn**
- `GET /api/linkedin/profiles` - List user's LinkedIn profiles
- `POST /api/linkedin/profiles` - Add new profile
- `PUT /api/linkedin/profiles/[id]` - Update profile
- `DELETE /api/linkedin/profiles/[id]` - Delete profile

## 🎨 Frontend Architecture

### Component Hierarchy
```
App Layout
├── Navigation Sidebar
├── Top Bar (User menu, notifications)
└── Main Content Area
    ├── Dashboard (Overview, stats, quick actions)
    ├── Calendar View (Month/week/day views)
    ├── Event Discovery (Gary's Guide integration)
    ├── Event Creation (AI extraction, manual form)
    ├── LinkedIn Connections (Profile management)
    └── Settings (Preferences, integrations)
```

### State Management
- **Server State**: React Query for API data fetching
- **Client State**: React hooks for UI state
- **Form State**: React Hook Form for complex forms
- **Global State**: React Context for app-wide state

### Styling System
- **Tailwind CSS** for utility-first styling
- **Custom Design System** with consistent colors, typography, and spacing
- **Responsive Design** with mobile-first approach
- **Dark Mode Ready** (framework in place)

## 🔒 Security Considerations

### Authentication
- **OAuth 2.0** with Google for secure authentication
- **JWT tokens** for session management
- **CSRF protection** via NextAuth.js
- **Secure cookies** with httpOnly and sameSite flags

### API Security
- **Route protection** with session validation
- **Input validation** with Zod schemas
- **Rate limiting** for API endpoints
- **SQL injection prevention** via Prisma ORM

### Data Privacy
- **GDPR compliance** ready
- **Data encryption** at rest and in transit
- **User data deletion** capabilities
- **Privacy-first design** principles

## 🚀 Performance Optimizations

### Frontend
- **Server-Side Rendering** with Next.js App Router
- **Image optimization** with Next.js Image component
- **Code splitting** and lazy loading
- **Caching strategies** for API responses

### Backend
- **Database indexing** for fast queries
- **Connection pooling** with Prisma
- **API response caching** for external services
- **Optimized database queries** with Prisma

### Deployment
- **Vercel Edge Network** for global distribution
- **Serverless functions** for API routes
- **Static asset optimization** and CDN delivery
- **Automatic scaling** based on demand

## 🔄 Integration Points

### External Services
1. **OpenAI API**
   - GPT-4 Vision for image analysis
   - Text completion for smart suggestions
   - Embeddings for semantic search

2. **Google Calendar API**
   - Event synchronization
   - Calendar access and management
   - Real-time updates

3. **Gary's Guide**
   - Event data scraping
   - Real-time updates
   - Event categorization

4. **LinkedIn API** (Future)
   - Profile data enrichment
   - Connection management
   - Messaging automation

## 📈 Scalability Considerations

### Database Scaling
- **Read replicas** for query performance
- **Database sharding** for large datasets
- **Connection pooling** for concurrent users
- **Caching layer** with Redis

### Application Scaling
- **Horizontal scaling** with serverless functions
- **Load balancing** across multiple regions
- **Auto-scaling** based on traffic patterns
- **Background job processing** for heavy tasks

### Monitoring & Observability
- **Error tracking** with built-in error boundaries
- **Performance monitoring** via Vercel Analytics
- **Database metrics** through Prisma
- **Custom logging** for debugging

## 🧪 Testing Strategy

### Testing Pyramid
1. **Unit Tests** - Individual functions and components
2. **Integration Tests** - API routes and database operations
3. **E2E Tests** - Critical user journeys
4. **Visual Tests** - UI component consistency

### Test Coverage Goals
- **80%+ code coverage** for critical paths
- **API endpoint testing** for all routes
- **Database operation testing** with test database
- **UI component testing** with React Testing Library

## 🔮 Future Enhancements

### Planned Features
1. **Real-time Collaboration** - WebSocket-based live updates
2. **Mobile App** - React Native version
3. **Advanced Analytics** - Event attendance tracking
4. **Team Management** - Multi-user organization features
5. **Calendar Integrations** - Outlook, Apple Calendar support
6. **AI Improvements** - Better extraction accuracy, smart scheduling

### Technical Improvements
1. **Offline Support** - Service worker implementation
2. **Progressive Web App** - PWA capabilities
3. **Advanced Caching** - Redis integration
4. **Microservices** - Service decomposition for scale
5. **GraphQL API** - More efficient data fetching
6. **Real-time Features** - WebSocket implementation

---

This architecture provides a solid foundation for a scalable, maintainable, and feature-rich calendar management platform that can grow with user needs and technological advances.
