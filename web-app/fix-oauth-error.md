# Fix OAuth "invalid_client" Error

## Error: 401 invalid_client - "The OAuth client was not found"

This error means Google can't find the OAuth client with the Client ID you're using.

## Common Causes & Solutions

### 1. **Client ID Mismatch**
The Client ID in your `.env.local` doesn't match what's in Google Cloud Console.

**Fix:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: **APIs & Services** → **Credentials**
3. Find your OAuth 2.0 Client ID
4. Click on it to view details
5. **Copy the exact Client ID** (should end with `.apps.googleusercontent.com`)
6. Update your `.env.local` file with the correct Client ID

### 2. **Wrong Google Cloud Project**
You might be using credentials from a different project.

**Fix:**
- Make sure you're in the correct Google Cloud project
- Check the project name at the top of Google Cloud Console
- Create a new OAuth client in the correct project if needed

### 3. **Redirect URI Mismatch**
The redirect URI in your request doesn't match what's configured.

**Required in Google Cloud Console:**
- **Authorized redirect URIs:** `http://localhost:3001/api/auth/callback/google`

**Check:**
1. Go to your OAuth client settings
2. Verify the redirect URI is exactly: `http://localhost:3001/api/auth/callback/google`
3. Make sure there are no trailing slashes or typos

### 4. **Client Was Deleted or Disabled**
The OAuth client might have been deleted or disabled.

**Fix:**
1. Check if the client exists in Google Cloud Console
2. If deleted, create a new one
3. If disabled, enable it

## Step-by-Step Fix

### Step 1: Verify Client ID in Google Cloud Console
1. Go to: https://console.cloud.google.com/apis/credentials
2. Find your OAuth 2.0 Client ID
3. Click on it
4. Copy the **Client ID** (full string)

### Step 2: Update .env.local
```bash
cd /Users/weijiahuang/Desktop/FoundersEvents/web-app
nano .env.local
```

Update these lines:
```env
GOOGLE_CLIENT_ID="paste-exact-client-id-here.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="paste-exact-client-secret-here"
```

### Step 3: Verify Redirect URI
In Google Cloud Console, under your OAuth client:
- **Authorized redirect URIs** must include:
  ```
  http://localhost:3001/api/auth/callback/google
  ```

### Step 4: Restart Dev Server
```bash
# Stop the server (Ctrl+C)
# Then restart
npm run dev
```

### Step 5: Test Again
1. Visit: http://localhost:3001
2. Click "Sign in with Google"
3. Should redirect to Google sign-in (not error page)

## Quick Verification

Run this to check your current config:
```bash
node test-google-auth.js
```

## Still Not Working?

1. **Create a new OAuth client:**
   - Go to Google Cloud Console → Credentials
   - Click "Create Credentials" → "OAuth client ID"
   - Application type: **Web application**
   - Name: "FoundersEvents Web Client"
   - Authorized JavaScript origins: `http://localhost:3001`
   - Authorized redirect URIs: `http://localhost:3001/api/auth/callback/google`
   - Click "Create"
   - Copy the new Client ID and Secret

2. **Double-check the email:**
   - Make sure `hello@joinaltare.com` is added as a test user
   - Go to: OAuth consent screen → Test users → Add Users

3. **Check OAuth consent screen:**
   - Make sure it's configured (User Type, App name, etc.)
   - Publishing status can be "Testing" for now

## Need Help?

If still not working, check:
- Browser console for more error details
- Google Cloud Console → APIs & Services → OAuth consent screen → Test users
- Make sure Google+ API or Google Identity API is enabled

