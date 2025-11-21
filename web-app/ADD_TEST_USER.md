# Fix "Access Denied" Error - Add Test User

## Error: 403 access_denied
"FounderEvents has not completed the Google verification process. The app is currently being tested, and can only be accessed by developer-approved testers."

## Quick Fix (2 minutes)

### Step 1: Go to OAuth Consent Screen
1. Open: https://console.cloud.google.com/apis/credentials/consent
2. Make sure you're in the correct project: **FounderEvents**

### Step 2: Add Test Users
1. Scroll down to the **"Test users"** section
2. Click **"+ ADD USERS"** button
3. Add your email address: **hhuangweijia@gmail.com**
4. Click **"ADD"**

### Step 3: Try Signing In Again
1. Go back to: http://localhost:3001
2. Click "Sign in with Google"
3. Should work now! ✅

## Visual Guide

```
Google Cloud Console
└── APIs & Services
    └── OAuth consent screen
        └── Test users section
            └── + ADD USERS
                └── Enter: hhuangweijia@gmail.com
                    └── ADD
```

## Important Notes

- **Test users only:** In testing mode, ONLY emails you add can sign in
- **No limit:** You can add multiple test users
- **Production:** Once you publish the app, anyone can sign in (after Google verification)

## Alternative: Publish the App (Not Recommended for Development)

If you want anyone to sign in (not just test users):
1. Go to OAuth consent screen
2. Click "PUBLISH APP"
3. Note: This requires Google verification for production apps

**For development, just add test users - it's easier!**

