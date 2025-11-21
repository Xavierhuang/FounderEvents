# ScheduleShare Web - Deployment Guide

## Prerequisites

Before deploying, ensure you have:
- Node.js 18+ installed
- PostgreSQL database (or Vercel Postgres)
- OpenAI API key
- Google OAuth credentials
- Google Calendar API enabled

## Environment Variables

Create a `.env.local` file with the following variables:

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

## Local Development

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up the database:**
   ```bash
   npm run db:generate
   npm run db:push
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser:**
   Navigate to [http://localhost:3000](http://localhost:3000)

## Deployment to Vercel

### 1. Prepare Your Repository

Ensure your code is pushed to GitHub, GitLab, or Bitbucket.

### 2. Connect to Vercel

1. Go to [vercel.com](https://vercel.com)
2. Click "Add New Project"
3. Import your repository
4. Select the `web-app` folder as the root directory

### 3. Configure Environment Variables

In the Vercel dashboard, add all environment variables from your `.env.local` file:

- `DATABASE_URL` (use Vercel Postgres)
- `NEXTAUTH_SECRET`
- `NEXTAUTH_URL` (your Vercel URL)
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `OPENAI_API_KEY`

### 4. Set Up Vercel Postgres

1. In your Vercel project, go to "Storage"
2. Click "Create Database"
3. Select "Postgres"
4. Copy the connection strings to your environment variables

### 5. Run Database Migrations

After deployment, run migrations in the Vercel dashboard terminal:

```bash
npx prisma db push
```

### 6. Configure Google OAuth

Update your Google Cloud Console OAuth settings:
- Add your Vercel URL to authorized JavaScript origins
- Add `https://your-domain.vercel.app/api/auth/callback/google` to redirect URIs

### 7. Deploy

Click "Deploy" in Vercel. Your app will be built and deployed automatically.

## Post-Deployment

### Test Your Deployment

1. Visit your Vercel URL
2. Sign in with Google
3. Test all features:
   - Event creation (AI and manual)
   - Event discovery
   - LinkedIn connections
   - Calendar sync
   - Route planning

### Set Up Custom Domain (Optional)

1. In Vercel dashboard, go to "Domains"
2. Add your custom domain
3. Follow DNS configuration instructions
4. Update `NEXTAUTH_URL` environment variable

### Monitor Your App

- Check Vercel Analytics for performance metrics
- Monitor OpenAI API usage in OpenAI dashboard
- Check database metrics in Vercel Postgres

## Troubleshooting

### Build Failures

- Check build logs in Vercel dashboard
- Ensure all dependencies are in `package.json`
- Verify TypeScript types are correct

### Database Issues

- Confirm DATABASE_URL is correct
- Check Prisma schema is up to date
- Run `npx prisma generate` locally and commit changes

### Authentication Issues

- Verify Google OAuth credentials
- Check NEXTAUTH_SECRET is set
- Confirm redirect URIs match Vercel URL

### API Errors

- Check OpenAI API key is valid
- Verify Google Calendar API is enabled
- Monitor Vercel function logs

## Scaling Considerations

### Database

- Monitor connection pool usage
- Consider read replicas for high traffic
- Set up automated backups

### Serverless Functions

- Vercel has default timeout limits (10s for Hobby, 60s for Pro)
- Optimize AI requests for speed
- Use caching where possible

### Monitoring

- Set up Vercel alerts
- Monitor API usage and costs
- Track error rates

## Security Best Practices

1. **Environment Variables**
   - Never commit secrets to git
   - Rotate secrets regularly
   - Use different keys for production/staging

2. **API Keys**
   - Set usage limits in OpenAI dashboard
   - Monitor for unusual activity
   - Use least privilege access

3. **Database**
   - Use connection pooling
   - Enable SSL connections
   - Regular security updates

4. **Authentication**
   - Use secure NEXTAUTH_SECRET (32+ characters)
   - Enable 2FA for admin accounts
   - Monitor failed login attempts

## Backup and Recovery

### Database Backups

Set up automated backups in Vercel Postgres:
- Daily backups retained for 7 days
- Weekly backups retained for 4 weeks
- Manual backups before major changes

### Code Backups

- Keep git history clean
- Tag releases
- Maintain staging environment

## Cost Optimization

### Vercel

- Start with Hobby plan ($0/month)
- Upgrade to Pro if needed ($20/month)
- Monitor bandwidth usage

### OpenAI

- Set monthly spending limits
- Cache AI responses when possible
- Use cheaper models for simple tasks

### Database

- Start with smallest Vercel Postgres plan
- Scale up as needed
- Optimize queries for performance

## Support

For issues or questions:
- Check documentation: `/web-app/README.md`
- Review architecture: `/web-app/ARCHITECTURE.md`
- Submit issues on GitHub
- Contact support@scheduleshare.app

---

**Deployment Checklist:**

- [ ] Environment variables configured
- [ ] Database set up and migrated
- [ ] Google OAuth configured
- [ ] OpenAI API key added
- [ ] Build succeeds locally
- [ ] All tests passing
- [ ] Google Calendar API enabled
- [ ] Vercel deployment successful
- [ ] Authentication working
- [ ] All features tested
- [ ] Custom domain configured (optional)
- [ ] Monitoring set up

**Congratulations! Your ScheduleShare web app is now live! 🎉**

