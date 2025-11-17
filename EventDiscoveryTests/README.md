# Event Discovery Tests

This folder contains separate test components for AI event discovery and web scraping functionality. Testing each component independently helps with debugging and ensures each piece works before integration.

## 📁 Folder Structure

```
EventDiscoveryTests/
├── TestLauncher.swift              # Main launcher for all tests
├── AIEventDiscoveryTest/
│   └── AIEventDiscoveryTest.swift  # Test AI-powered event discovery
├── WebScrapingTest/
│   └── WebScrapingTest.swift       # Test web scraping functionality
├── IntegrationTest/
│   └── IntegrationTest.swift        # Test combined AI + scraping
└── README.md                       # This file
```

## 🧪 Test Components

### 1. AI Event Discovery Test (`AIEventDiscoveryTest.swift`)
- **Purpose**: Test OpenAI's ability to discover events
- **Features**:
  - Customizable search query and location
  - JSON response parsing
  - Event result display
  - Error handling

### 2. Web Scraping Test (`WebScrapingTest.swift`)
- **Purpose**: Test web scraping from event websites
- **Features**:
  - Multiple website testing (Eventbrite, Meetup, etc.)
  - HTML parsing and event extraction
  - Results summary
  - Error handling

### 3. Integration Test (`IntegrationTest.swift`)
- **Purpose**: Test combined AI discovery + web scraping
- **Features**:
  - Combined results from both sources
  - Deduplication
  - Source filtering
  - Performance comparison

## 🚀 Getting Started

### Prerequisites
1. **OpenAI API Key**: Add your API key to the test files
2. **Dependencies**: Ensure OpenAI SDK is included in your project

### Setup Steps
1. **Add API Key**: Replace `"YOUR_OPENAI_API_KEY_HERE"` with your actual API key
2. **Run Tests**: Use `TestLauncher.swift` to access all test components
3. **Test Order**: Start with AI discovery, then web scraping, finally integration

## 📋 Testing Strategy

### Phase 1: AI Event Discovery (Recommended First)
```swift
// Easy to test and debug
// Reliable results
// Good for initial validation
```

### Phase 2: Web Scraping
```swift
// More complex
// Requires HTML parsing
// May need site-specific logic
```

### Phase 3: Integration
```swift
// Combines both approaches
// Tests deduplication
// Validates end-to-end flow
```

## 🔧 Configuration

### OpenAI API Setup
```swift
// In each test file, update this line:
private let openAI = OpenAI(apiToken: "YOUR_ACTUAL_API_KEY")
```

### Test Websites
```swift
// Update these URLs in WebScrapingTest.swift:
private let testWebsites = [
    "Eventbrite": "https://www.eventbrite.com/d/united-states--new-york/tech/",
    "Meetup": "https://www.meetup.com/find/?source=EVENTS&location=us--ny--new-york",
    // Add more sites as needed
]
```

## 🐛 Troubleshooting

### Common Issues

1. **AI Response Parsing Errors**
   - Check that OpenAI returns valid JSON
   - Verify date format (ISO8601)
   - Ensure response structure matches expected format

2. **Web Scraping Failures**
   - Some websites may block scraping
   - Check network connectivity
   - Verify URL accessibility

3. **Integration Issues**
   - Ensure both AI and scraping components work independently
   - Check deduplication logic
   - Verify data format consistency

### Debug Tips

1. **Console Logging**: Check console for detailed error messages
2. **Step-by-Step Testing**: Test each component separately first
3. **API Limits**: Be mindful of OpenAI API rate limits
4. **Network Issues**: Ensure stable internet connection for web scraping

## 📊 Expected Results

### AI Discovery
- Should return 3-10 events per search
- Events should have valid dates and locations
- Confidence scores should be > 0.7

### Web Scraping
- Should extract 5-15 events per website
- Events should have basic information (title, date)
- Source attribution should be accurate

### Integration
- Combined results should be > individual component results
- Deduplication should reduce total count
- Performance should be reasonable (< 30 seconds)

## 🔄 Next Steps

After successful testing:

1. **Integrate into Main App**: Move working components to main app
2. **Optimize Performance**: Improve response times and reliability
3. **Add More Sources**: Expand web scraping to more sites
4. **Enhance AI Prompts**: Improve event discovery accuracy
5. **User Interface**: Create user-friendly event discovery interface

## 📝 Notes

- **API Costs**: OpenAI API calls incur costs, monitor usage
- **Rate Limits**: Respect website rate limits for scraping
- **Legal Considerations**: Ensure scraping complies with website terms
- **Data Quality**: Validate extracted event information
- **Error Handling**: Implement robust error handling for production use 