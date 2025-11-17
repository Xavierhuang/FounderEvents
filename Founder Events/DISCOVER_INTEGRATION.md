# Discover Tab Integration - Gary's Guide Events

## Overview

The ScheduleShare app now includes a **Discover** tab that allows users to browse and register for events from Gary's Guide, a popular NYC tech events website.

## Features

### 🎯 Event Discovery
- **Browse Events**: View all available events from Gary's Guide
- **Filter by Week**: Filter events by specific weeks (Aug 04, Aug 11, etc.)
- **Filter by Type**: Filter by event categories:
  - All Events
  - Popular Events (highly attended events)
  - Free Events
  - Paid Events

### 🎪 Event Information
Each event displays:
- **Title**: Event name
- **Date & Time**: When the event takes place
- **Price**: Free or paid events with pricing
- **Venue**: Location information
- **Speakers**: Featured speakers and organizers
- **Event Type**: Popular Event or Regular Event badges

### 🔗 Registration & Navigation
- **View Details**: Tap to see full event information
- **Open in Safari**: Direct link to event registration page
- **Web View**: In-app browser for event details
- **External Registration**: Seamless navigation to Gary's Guide for registration

## Implementation Details

### Files Created/Modified

1. **`GarysGuideEvent.swift`**
   - Event model with all necessary properties
   - Service class for managing events
   - Filtering and data management

2. **`DiscoverView.swift`**
   - Main discover interface
   - Event cards with filtering
   - Detail views and navigation

3. **`GarysGuideScraper.swift`**
   - Web scraping service (framework ready)
   - Sample data integration
   - Registration helper functions

4. **`ContentView.swift`**
   - Added Discover tab to main navigation
   - Updated tab structure

### Data Structure

```swift
struct GarysGuideEvent: Identifiable, Codable, Equatable {
    let id = UUID()
    let title: String
    let date: String
    let time: String
    let price: String
    let venue: String
    let speakers: String
    let url: String
    let isGaryEvent: Bool
    let isPopularEvent: Bool
    let week: String
}
```

### Sample Events Included

#### Week of Aug 04 (6 events)
- **Startup Luncheon** - Free
- **Startup Mixer** - Free
- **How GTM Teams Are Changing In 2025** (Popular Event) - Free
- **Liquid Equity** (Popular Event) - Free
- **Cross-University Fast Pitch Night** - Free
- **Long Island Technologists Meetup** (Popular Event) - Free

#### Week of Aug 11 (5 events)
- **Scaling AI w/ Confidence Workshop** - Free
- **Mapping For Equity - Data Entry** (Popular Event) - Free
- **Entrepreneurs Roundtable** - Free
- **NextFin** - Free
- **How To Win A $1M Pitch Competition** (Popular Event) - Free

#### Paid Events
- **Startup Friends - Tea, Stretch & Chill** - $35
- **Pragma Founder Talks** - $99

## User Experience

### Navigation Flow
1. **Discover Tab**: Users tap the magnifying glass icon
2. **Browse Events**: View all events with filtering options
3. **Filter Options**: 
   - Horizontal scroll for week selection
   - Horizontal scroll for event type selection
4. **Event Details**: Tap any event card to see details
5. **Registration**: 
   - "View Event Details" opens in-app web view
   - "Open in Safari" opens external browser for registration

### Visual Design
- **Event Cards**: Clean, modern design with shadows
- **Badges**: Color-coded event types (Blue for Popular Events)
- **Price Tags**: Green for free events, Orange for paid events
- **Loading States**: Smooth loading animations
- **Empty States**: Helpful messages when no events match filters

## Technical Implementation

### Web Scraping Integration
The app includes a framework for real web scraping:

```swift
class GarysGuideScraper: ObservableObject {
    private let garysGuideURL = "https://www.garysguide.com/events"
    
    func fetchEvents() {
        // Real HTTP request to Gary's Guide
        // HTML parsing and event extraction
    }
}
```

### Current Status
- ✅ **Sample Data**: 12 events from Gary's Guide
- ✅ **UI Implementation**: Complete discover interface
- ✅ **Navigation**: Full event detail and registration flow
- ✅ **Filtering**: Week and event type filters
- 🔄 **Real Scraping**: Framework ready, using sample data

### Future Enhancements
1. **Real Web Scraping**: Implement actual HTTP requests to Gary's Guide
2. **Auto-refresh**: Periodic updates of event data
3. **Push Notifications**: New event alerts
4. **Calendar Integration**: Add events directly to user's calendar
5. **Favorites**: Save interesting events for later
6. **Search**: Text search through events

## Usage Instructions

### For Users
1. Open ScheduleShare app
2. Tap the **Discover** tab (magnifying glass icon)
3. Browse events or use filters to find specific events
4. Tap any event to see details
5. Use "Open in Safari" to register for events

### For Developers
1. The scraping framework is ready for real implementation
2. Sample data can be replaced with live scraping
3. All UI components are reusable and extensible
4. Event model supports all Gary's Guide data fields

## Integration Benefits

- **Seamless Experience**: Users can discover and register for events without leaving the app
- **Rich Information**: Complete event details including speakers and venues
- **Smart Filtering**: Easy discovery of relevant events
- **Direct Registration**: One-tap access to event registration pages
- **Consistent Design**: Matches the app's existing design language

The Discover tab transforms ScheduleShare from a personal calendar app into a comprehensive event discovery and management platform! 