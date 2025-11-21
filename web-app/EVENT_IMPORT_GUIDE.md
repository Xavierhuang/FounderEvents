# Event Import Feature - Extract from Luma/Eventbrite

## Overview

The Event Import feature allows you to extract event data from Luma or Eventbrite URLs and create your own FoundersEvents link. This is perfect for:

- Importing events from other platforms
- Creating a unified event management system
- Rebranding events under FoundersEvents
- Building your own event community

## How It Works

### Step 1: Paste Event URL
1. Go to `/dashboard/events/import`
2. Paste a Luma or Eventbrite event URL
3. Select platform (or use auto-detect)

### Step 2: Extract Event Data
- Click "Extract Event"
- AI-powered extraction using GPT-4
- Automatically extracts:
  - Title, description
  - Date and time
  - Location (physical/virtual/hybrid)
  - Venue details
  - Price and capacity
  - Cover image
  - Tags and categories

### Step 3: Create Your Event
- Review extracted data
- Click "Create Event"
- Get your own FoundersEvents URL
- Share your unique link!

## Supported Platforms

### Luma
- URL format: `https://lu.ma/event/...`
- Extracts: All event details, RSVP info, location

### Eventbrite
- URL format: `https://www.eventbrite.com/e/...`
- Extracts: Event details, pricing, venue, capacity

## API Endpoint

### POST `/api/events/extract-from-url`

**Request:**
```json
{
  "url": "https://lu.ma/event/example",
  "platform": "auto" // or "luma" or "eventbrite"
}
```

**Response:**
```json
{
  "success": true,
  "extractedData": {
    "title": "Event Title",
    "description": "Full description...",
    "shortDescription": "Short description",
    "startDate": "2024-12-15T18:00:00Z",
    "endDate": "2024-12-15T20:00:00Z",
    "locationType": "PHYSICAL",
    "venueName": "Venue Name",
    "venueAddress": "123 Main St",
    "venueCity": "New York",
    "venueState": "NY",
    "venueZipCode": "10001",
    "price": 0,
    "currency": "USD",
    "capacity": 100,
    "tags": ["tech", "networking"],
    "coverImage": "https://...",
    "originalUrl": "https://lu.ma/event/example",
    "platform": "luma"
  }
}
```

## Features

### AI-Powered Extraction
- Uses GPT-4 to intelligently parse HTML
- Handles different page layouts
- Extracts structured data

### Automatic Platform Detection
- Detects Luma vs Eventbrite from URL
- Can be manually overridden

### Data Validation
- Validates extracted dates
- Ensures required fields are present
- Provides defaults for missing data

### One-Click Creation
- Directly creates FoundersEvents event
- Generates unique slug
- Publishes immediately (or save as draft)

## Usage Examples

### Import from Luma
```
1. Copy Luma event URL: https://lu.ma/event/abc123
2. Paste in import page
3. Click "Extract Event"
4. Review and create
5. Get: https://foundersevents.app/events/your-event-slug
```

### Import from Eventbrite
```
1. Copy Eventbrite URL: https://www.eventbrite.com/e/xyz789
2. Paste in import page
3. Select "Eventbrite" platform
4. Extract and create
5. Share your FoundersEvents link!
```

## Technical Details

### Extraction Process
1. **Fetch HTML**: Downloads the event page
2. **AI Analysis**: GPT-4 analyzes HTML structure
3. **Data Extraction**: Extracts structured JSON
4. **Validation**: Validates and formats data
5. **Return**: Returns formatted event data

### Error Handling
- Invalid URLs → Clear error message
- Failed fetch → Network error handling
- Parse errors → Detailed error response
- Missing data → Uses sensible defaults

## Limitations

### Current Limitations
- Requires OpenAI API key
- May not work with password-protected events
- Some dynamic content may not be extracted
- Rate limits apply (OpenAI API)

### Future Enhancements
- Support for more platforms (Meetup, Facebook Events)
- Batch import (multiple URLs)
- Scheduled imports
- Webhook support
- Direct API integration with platforms

## Best Practices

### For Event Organizers
1. **Verify Data**: Always review extracted data before creating
2. **Add Details**: Enhance with additional information
3. **Update Images**: Use high-quality cover images
4. **Set Categories**: Add relevant tags and categories

### For Platform Admins
1. **Monitor Usage**: Track import success rates
2. **Improve Extraction**: Refine prompts based on failures
3. **Add Platforms**: Expand to more event platforms
4. **Cache Results**: Cache successful extractions

## Troubleshooting

### "Failed to fetch event page"
- Check if URL is accessible
- Verify URL format is correct
- Try accessing URL in browser first

### "Failed to extract event data"
- Event page might be dynamic/JavaScript-rendered
- Try manual entry instead
- Check OpenAI API key is valid

### "Missing required fields"
- Some events may have incomplete data
- Fill in missing fields manually
- Use defaults provided

## Security Considerations

- URLs are validated before fetching
- HTML content is sanitized
- No sensitive data is stored
- Rate limiting prevents abuse

## Cost Considerations

- Each extraction uses GPT-4 API (~$0.01-0.03)
- Consider caching successful extractions
- Monitor API usage in OpenAI dashboard

---

**Status**: ✅ Implemented and Ready

**Next Steps**: Test with real Luma/Eventbrite URLs and refine extraction prompts based on results.

