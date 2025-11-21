/**
 * Test script to verify Google OAuth configuration
 * Run with: node test-google-auth.js
 */

require('dotenv').config({ path: '.env.local' });

console.log('🔍 Testing Google OAuth Configuration...\n');

// Check environment variables
const clientId = process.env.GOOGLE_CLIENT_ID;
const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
const nextAuthUrl = process.env.NEXTAUTH_URL;
const nextAuthSecret = process.env.NEXTAUTH_SECRET;

console.log('📋 Environment Variables Check:');
console.log('─────────────────────────────────');

if (!clientId) {
  console.log('❌ GOOGLE_CLIENT_ID: Missing');
} else if (clientId.includes('your-google-client-id')) {
  console.log('❌ GOOGLE_CLIENT_ID: Still has placeholder value');
} else {
  console.log('✅ GOOGLE_CLIENT_ID: Set');
  console.log(`   Value: ${clientId.substring(0, 30)}...`);
}

if (!clientSecret) {
  console.log('❌ GOOGLE_CLIENT_SECRET: Missing');
} else if (clientSecret.includes('your-google-client-secret')) {
  console.log('❌ GOOGLE_CLIENT_SECRET: Still has placeholder value');
} else {
  console.log('✅ GOOGLE_CLIENT_SECRET: Set');
  console.log(`   Value: ${clientSecret.substring(0, 10)}...`);
}

if (!nextAuthUrl) {
  console.log('❌ NEXTAUTH_URL: Missing');
} else {
  console.log('✅ NEXTAUTH_URL: Set');
  console.log(`   Value: ${nextAuthUrl}`);
}

if (!nextAuthSecret) {
  console.log('❌ NEXTAUTH_SECRET: Missing');
} else if (nextAuthSecret.length < 32) {
  console.log('⚠️  NEXTAUTH_SECRET: Too short (should be at least 32 characters)');
} else {
  console.log('✅ NEXTAUTH_SECRET: Set');
}

console.log('\n🔗 OAuth URLs:');
console.log('─────────────────────────────────');
console.log(`Authorization URL: ${nextAuthUrl}/api/auth/signin`);
console.log(`Callback URL: ${nextAuthUrl}/api/auth/callback/google`);

console.log('\n📝 Configuration Checklist:');
console.log('─────────────────────────────────');

// Validate Client ID format
if (clientId && clientId.endsWith('.apps.googleusercontent.com')) {
  console.log('✅ Client ID format is correct');
} else if (clientId) {
  console.log('⚠️  Client ID format may be incorrect');
}

// Validate Client Secret format
if (clientSecret && clientSecret.startsWith('GOCSPX-')) {
  console.log('✅ Client Secret format is correct (GOCSPX- prefix)');
} else if (clientSecret) {
  console.log('⚠️  Client Secret format may be incorrect');
}

console.log('\n🌐 Next Steps:');
console.log('─────────────────────────────────');
console.log('1. Make sure these URLs are added in Google Cloud Console:');
console.log(`   - Authorized JavaScript origins: ${nextAuthUrl}`);
console.log(`   - Authorized redirect URIs: ${nextAuthUrl}/api/auth/callback/google`);
console.log('\n2. Add your email as a test user in OAuth consent screen');
console.log('\n3. Visit the app and click "Sign in with Google"');
console.log(`   URL: ${nextAuthUrl}`);

console.log('\n✨ Test complete!\n');

