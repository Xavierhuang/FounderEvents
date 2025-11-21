/**
 * Test NextAuth API endpoint
 * Run with: node test-auth-endpoint.js
 */

const http = require('http');

const testUrl = 'http://localhost:3001/api/auth/providers';

console.log('🔍 Testing NextAuth API Endpoint...\n');
console.log(`Testing: ${testUrl}\n`);

const req = http.get(testUrl, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📡 Response Status:', res.statusCode);
    console.log('─────────────────────────────────\n');

    if (res.statusCode === 200) {
      try {
        const providers = JSON.parse(data);
        console.log('✅ NextAuth is working!');
        console.log('\n📋 Available Providers:');
        
        if (providers.google) {
          console.log('✅ Google OAuth provider is configured');
          console.log(`   Name: ${providers.google.name}`);
          console.log(`   ID: ${providers.google.id}`);
          console.log(`   Type: ${providers.google.type}`);
        } else {
          console.log('❌ Google OAuth provider not found');
        }
      } catch (e) {
        console.log('⚠️  Response is not valid JSON');
        console.log('Response:', data.substring(0, 200));
      }
    } else {
      console.log(`❌ Server returned status ${res.statusCode}`);
      console.log('Response:', data.substring(0, 200));
    }

    console.log('\n✨ Test complete!\n');
  });
});

req.on('error', (error) => {
  console.log('❌ Error connecting to server');
  console.log('─────────────────────────────────');
  console.log('Make sure the dev server is running:');
  console.log('  cd web-app && npm run dev\n');
  console.log('Error:', error.message);
  console.log('\n');
});

req.setTimeout(5000, () => {
  req.destroy();
  console.log('❌ Request timeout - server may not be running\n');
});

