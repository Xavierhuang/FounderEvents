#!/bin/bash

# ScheduleShare Web App Setup Script
# Automates the initial setup process

set -e

echo "🚀 Setting up ScheduleShare Web App..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version 18 or higher is required. Current version: $(node -v)"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from template..."
    cp env.example .env.local
    echo "⚠️  Please edit .env.local with your actual configuration values:"
    echo "   - DATABASE_URL"
    echo "   - NEXTAUTH_SECRET"
    echo "   - GOOGLE_CLIENT_ID & GOOGLE_CLIENT_SECRET"
    echo "   - OPENAI_API_KEY"
fi

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# Check if database is accessible
echo "🗄️  Checking database connection..."
if npx prisma db push --accept-data-loss &> /dev/null; then
    echo "✅ Database connection successful and schema updated"
else
    echo "⚠️  Database connection failed. Please check your DATABASE_URL in .env.local"
    echo "   You can set up a local PostgreSQL database or use a cloud service like:"
    echo "   - Vercel Postgres"
    echo "   - Supabase"
    echo "   - Railway"
    echo "   - PlanetScale"
fi

# Create uploads directory
mkdir -p uploads
echo "✅ Created uploads directory"

# Run type checking
echo "🔍 Running type checking..."
if npm run type-check; then
    echo "✅ Type checking passed"
else
    echo "⚠️  Type checking found issues. Please review and fix them."
fi

echo ""
echo "🎉 Setup complete! Next steps:"
echo ""
echo "1. Edit .env.local with your configuration:"
echo "   - Set up your database URL"
echo "   - Add your Google OAuth credentials"
echo "   - Add your OpenAI API key"
echo ""
echo "2. Start the development server:"
echo "   npm run dev"
echo ""
echo "3. Visit http://localhost:3000 to see your app!"
echo ""
echo "📚 For more information, see README.md"
echo ""

# Optional: Open the app in browser (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "🌐 Would you like to open the setup guide in your browser? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "https://github.com/your-username/scheduleshare-web#-configuration"
    fi
fi
