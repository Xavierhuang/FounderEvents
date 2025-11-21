/**
 * Test script to verify Anthropic API key
 * Run with: node test-anthropic.js
 */

require('dotenv').config({ path: '.env.local' });
const Anthropic = require('@anthropic-ai/sdk');

console.log('🔍 Testing Anthropic API Key...\n');

const apiKey = process.env.ANTHROPIC_API_KEY;

if (!apiKey) {
  console.log('❌ ANTHROPIC_API_KEY not found in .env.local');
  process.exit(1);
}

console.log('✅ API Key found in environment');
console.log(`   Key starts with: ${apiKey.substring(0, 20)}...`);
console.log(`   Key length: ${apiKey.length} characters\n`);

console.log('🧪 Testing API connection...\n');

const anthropic = new Anthropic({
  apiKey: apiKey,
});

async function testAPI() {
  try {
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-5',
      max_tokens: 100,
      messages: [
        {
          role: 'user',
          content: 'Say "Hello, FoundersEvents!" if you can read this.',
        },
      ],
    });

    console.log('✅ API Connection Successful!\n');
    console.log('📝 Response from Claude:');
    console.log('─────────────────────────────────');
    
    if (message.content[0]?.type === 'text') {
      console.log(message.content[0].text);
    } else {
      console.log('Unexpected response format:', message.content);
    }
    
    console.log('─────────────────────────────────\n');
    console.log('✨ Anthropic API is working correctly!');
    console.log(`   Model: ${message.model}`);
    console.log(`   Tokens used: ${message.usage?.input_tokens || 0} input, ${message.usage?.output_tokens || 0} output`);
    console.log('\n✅ Ready to extract events from Luma/Eventbrite URLs!\n');
    
  } catch (error) {
    console.log('❌ API Connection Failed\n');
    console.log('Error:', error.message);
    
    if (error.status === 401) {
      console.log('\n💡 This means the API key is invalid or expired.');
      console.log('   Please check your API key at: https://console.anthropic.com/');
    } else if (error.status === 429) {
      console.log('\n💡 Rate limit exceeded. Please wait a moment and try again.');
    } else if (error.status === 500) {
      console.log('\n💡 Anthropic server error. Please try again in a moment.');
    } else {
      console.log('\n💡 Error details:', error);
    }
    
    process.exit(1);
  }
}

testAPI();

