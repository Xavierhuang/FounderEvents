# Featured Events Guide

## Overview
The Featured Events feature allows event organizers to highlight their most important public events, giving them premium placement in the discovery section.

## What's New

### Database Changes
- Added `isFeatured` boolean field to `PublicEvent` model
- Defaults to `false` for all new events

### API Endpoints

#### Feature an Event
```bash
POST /api/public-events/{slug}/feature
Body: { "isFeatured": true }
```

#### Get Featured Events
```bash
GET /api/public-events?isFeatured=true
```

### UI Features

#### Event Discovery Page (`/events`)
1. **Three Filter Tabs:**
   - **All Events**: Shows all upcoming public events
   - **Featured Events**: Shows only featured events (with star icon)
   - **Popular Events**: Shows events sorted by registration count

2. **Visual Indicators:**
   - Featured events display a yellow "FEATURED" badge with star icon
   - Badge appears in top-right corner of event card
   - Featured events have priority visibility

#### Event Cards
```tsx
{event.isFeatured && (
  <div className="bg-yellow-500 text-white px-3 py-1 rounded-full">
    <StarIcon /> FEATURED
  </div>
)}
```

## How to Feature an Event

### For Event Organizers

1. **Navigate to Your Events Dashboard**
   - Go to `/dashboard/my-events`
   - Find the event you want to feature

2. **Toggle Featured Status**
   - Click "Feature Event" button
   - Event will now appear in Featured Events section

3. **API Call**
   ```javascript
   await fetch(`/api/public-events/${eventSlug}/feature`, {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify({ isFeatured: true })
   });
   ```

### For Admins (Future Enhancement)

In production, you might want to:
- Add admin role to User model
- Restrict featuring to admins only
- Add approval workflow for featured events
- Set limits on number of featured events

## Database Migration

After updating the schema, run:

```bash
cd web-app
npx prisma db push
# or
npx prisma migrate dev --name add-featured-events
```

## Featured Events Display Logic

### Filtering
```typescript
// Show only featured events
const where = {
  status: 'PUBLISHED',
  visibility: 'PUBLIC',
  isFeatured: true,
  startDate: { gte: new Date() }
};
```

### Sorting
Featured events appear:
1. In dedicated "Featured Events" tab
2. With visual prominence (star badge)
3. Can be combined with other filters (location, price, etc.)

## UI Components

### Featured Badge Component
```tsx
{event.isFeatured && (
  <div className="absolute top-4 right-4 z-10">
    <div className="bg-yellow-500 text-white px-3 py-1 rounded-full text-xs font-bold flex items-center shadow-lg">
      <StarIcon className="h-4 w-4 mr-1" />
      FEATURED
    </div>
  </div>
)}
```

### Filter Tabs
```tsx
<button
  onClick={() => setActiveFilter('featured')}
  className={activeFilter === 'featured'
    ? 'bg-yellow-500 text-white'
    : 'bg-white text-gray-700'
  }
>
  <StarIcon /> Featured Events
</button>
```

## Best Practices

### For Event Organizers
1. **Feature Your Best Events**: Use featuring for high-quality, well-planned events
2. **Limit Featured Events**: Don't feature every event to maintain quality
3. **Update Content**: Keep featured events up-to-date with complete information
4. **High-Quality Images**: Use professional cover images for featured events

### For Platform Admins
1. **Quality Control**: Review events before allowing featuring
2. **Rotation**: Consider rotating featured events to give all organizers visibility
3. **Criteria**: Establish clear criteria for what makes an event "feature-worthy"
4. **Analytics**: Track performance of featured vs non-featured events

## Future Enhancements

### Potential Features
1. **Featured Duration**: Time-limited featuring (e.g., 7 days)
2. **Featured Slots**: Limit number of concurrent featured events
3. **Featured Cost**: Monetize featuring as premium feature
4. **Auto-Featured**: Automatically feature events based on engagement
5. **Featured Homepage**: Dedicated carousel on homepage
6. **Featured Categories**: Feature events within specific categories
7. **Sponsored Events**: Paid promotion option

### Admin Dashboard
```typescript
// Future: Admin-only featuring
if (!user.isAdmin) {
  return { error: 'Admin access required' };
}
```

## Testing

### Test Featured Events
1. Create a public event
2. Call feature API endpoint
3. Verify "FEATURED" badge appears
4. Check event appears in Featured Events tab
5. Verify unfeaturing works correctly

### Test Queries
```bash
# Get all featured events
curl http://localhost:3000/api/public-events?isFeatured=true

# Feature an event
curl -X POST http://localhost:3000/api/public-events/my-event/feature \
  -H "Content-Type: application/json" \
  -d '{"isFeatured": true}'
```

## Analytics

Track featuring effectiveness:
- Click-through rate on featured vs non-featured
- Registration conversion for featured events
- Engagement metrics (likes, comments)
- ROI if featuring is monetized

## Support

For issues or questions about featured events:
- Check API documentation
- Review database schema
- Test with sample data
- Contact support team

---

**Status**: ✅ Implemented and Ready for Production

**Version**: 1.0  
**Last Updated**: 2024

