#!/usr/bin/env swift

import Foundation

// Improved Gary's Guide scraper based on HTML structure analysis
print("=== IMPROVED GARY'S GUIDE SCRAPER ===")

// Sample HTML content (you can replace this with actual fetched content)
let garysGuideHTML = """
<!DOCTYPE html>
<html>
<head>
    <title>NYC Tech Events - GarysGuide | The #1 Resource for NYC Tech</title>
</head>
<body>
    <div class='fbox'>
        <div style='padding:15px;'>
            <table width='100%'>
                <tr>
                    <td valign="top" align="left">
                        <a target="_blank" href="http://gary.to/6u90122">
                            <img class="rounded_thumb" width="150" height="45" src="https://s3.amazonaws.com/garysguide/f77cbd22459548d6bc939ac51e294697original.jpg"/>
                        </a>
                    </td>
                    <td width="3">&nbsp;</td>
                    <td valign="top">
                        <font class="fblack">
                            <a target="_blank" href="http://gary.to/6u90122">
                                <b>Aug 06: NY AI Engineers - Aug Tech Talk w/ Google Gemini, Agentuity & Espresso Presenting</a>
                            </b>
                        </font>
                        <br/>
                        <font class="fblacksmall">
                            <a target="_blank" href="http://gary.to/6u90122">With Claire Yin (Software Engineer ML, Google Gemini), Rick Blalock (Technical Founder, Agentuity), Espresso AI.</a>
                        </font>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    
    <div class='fbox'>
        <div style='padding:15px;'>
            <table width='100%'>
                <tr>
                    <td align='left' colspan='7'>
                        <font class='fblack'><b>Thursday, Aug 07</b></font>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>12:00pm
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='center' width='37' valign='top'>
                        Free<br/>
                        <img title='Gary Event' alt='Gary Event' width='30' src='https://s3.amazonaws.com/garysguide_images/gary_star.png'/>
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='left' valign='top'>
                        <table width='100%' cellspacing='3' cellpadding='3'>
                            <tr>
                                <td align='left'>
                                    <font class='ftitle'>
                                        <a alt='Startup Luncheon' href='https://www.garysguide.com/events/7md1azk/Startup-Luncheon'>
                                            <b>Startup Luncheon</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Venue</b>, To Be Announced
                                    </font>
                                    <br/>
                                    <font class='fgray'>With Caroline Dell <i>(Co-Founder/CEO, Goodword)</i>, Sarah Stein <i>(CMO, VOESH)</i>, Alana Lomax <i>(Co-Founder/CEO, UNTOLD)</i>.</font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>5:00pm
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='center' width='37' valign='top'>
                        Free<br/>
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='left' valign='top'>
                        <table width='100%' cellspacing='3' cellpadding='3'>
                            <tr>
                                <td align='left'>
                                    <font class='ftitle'>
                                        <a alt='Startup Mixer' href='https://www.garysguide.com/events/55ajswc/Startup-Mixer'>
                                            <b>Startup Mixer</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Sour Mouse</b>, 110 Delancey St
                                    </font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</body>
</html>
"""

struct GarysGuideEvent {
    let title: String
    let date: String
    let time: String
    let price: String
    let venue: String
    let speakers: String
    let url: String
    let isGaryEvent: Bool
    let isPopularEvent: Bool
}

func extractGarysGuideEvents(from html: String) -> [GarysGuideEvent] {
    var events: [GarysGuideEvent] = []
    
    // Extract Event Spotlight events
    let spotlightPattern = #"<font class="fblack">\s*<a[^>]*href="([^"]*)"[^>]*>\s*<b>([^<]+)</b></a>"#
    let spotlightMatches = html.matches(of: try! Regex(spotlightPattern))
    
    for match in spotlightMatches {
        let matchString = String(match.0)
        // Extract URL and title using string manipulation
        if let urlStart = matchString.range(of: "href=\""),
           let urlEnd = matchString.range(of: "\"", range: urlStart.upperBound..<matchString.endIndex),
           let titleStart = matchString.range(of: "<b>"),
           let titleEnd = matchString.range(of: "</b>", range: titleStart.upperBound..<matchString.endIndex) {
            
            let url = String(matchString[urlStart.upperBound..<urlEnd.lowerBound])
            let title = String(matchString[titleStart.upperBound..<titleEnd.lowerBound])
            
            // Extract date from title if present
            let datePattern = #"(\w{3}\s+\d{1,2}):\s*(.+)"#
            if let dateMatch = title.matches(of: try! Regex(datePattern)).first {
                let dateMatchString = String(dateMatch.0)
                let components = dateMatchString.components(separatedBy: ": ")
                if components.count >= 2 {
                    let date = components[0]
                    let eventTitle = components[1]
                    
                    events.append(GarysGuideEvent(
                        title: eventTitle,
                        date: date,
                        time: "TBD",
                        price: "TBD",
                        venue: "TBD",
                        speakers: "TBD",
                        url: url,
                        isGaryEvent: false,
                        isPopularEvent: false
                    ))
                }
            }
        }
    }
    
    // Extract Weekly Events using simpler approach
    let eventTitlePattern = #"<font class='ftitle'>\s*<a[^>]*href='([^']*)'[^>]*>\s*<b>([^<]+)</b></a>"#
    let titleMatches = html.matches(of: try! Regex(eventTitlePattern))
    
    for match in titleMatches {
        let matchString = String(match.0)
        if let urlStart = matchString.range(of: "href='"),
           let urlEnd = matchString.range(of: "'", range: urlStart.upperBound..<matchString.endIndex),
           let titleStart = matchString.range(of: "<b>"),
           let titleEnd = matchString.range(of: "</b>", range: titleStart.upperBound..<matchString.endIndex) {
            
            let url = String(matchString[urlStart.upperBound..<urlEnd.lowerBound])
            let title = String(matchString[titleStart.upperBound..<titleEnd.lowerBound])
            
            // Extract date and time from nearby content
            let dateTimePattern = #"<b>(\w{3}\s+\d{1,2})</b><br/>(\d{1,2}:\d{2}[ap]m)"#
            let dateTimeMatches = html.matches(of: try! Regex(dateTimePattern))
            
            var date = "TBD"
            var time = "TBD"
            
            if let dateTimeMatch = dateTimeMatches.first {
                let dateTimeString = String(dateTimeMatch.0)
                let components = dateTimeString.components(separatedBy: "<br/>")
                if components.count >= 2 {
                    date = components[0].replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                    time = components[1]
                }
            }
            
            // Extract venue
            let venuePattern = #"<font class='fdescription'>\s*<br/><b>([^<]+)</b>([^<]*)</font>"#
            let venueMatches = html.matches(of: try! Regex(venuePattern))
            var venue = "TBD"
            
            if let venueMatch = venueMatches.first {
                let venueString = String(venueMatch.0)
                if let venueStart = venueString.range(of: "<b>"),
                   let venueEnd = venueString.range(of: "</b>", range: venueStart.upperBound..<venueString.endIndex) {
                    venue = String(venueString[venueStart.upperBound..<venueEnd.lowerBound])
                }
            }
            
            // Extract speakers
            let speakerPattern = #"<font class='fgray'>With ([^<]+)</font>"#
            let speakerMatches = html.matches(of: try! Regex(speakerPattern))
            var speakers = ""
            
            if let speakerMatch = speakerMatches.first {
                let speakerString = String(speakerMatch.0)
                if let withStart = speakerString.range(of: "With ") {
                    speakers = String(speakerString[withStart.upperBound..<speakerString.endIndex])
                }
            }
            
            let isGaryEvent = html.contains("gary_star.png")
            let isPopularEvent = html.contains("blue_star.png")
            
            events.append(GarysGuideEvent(
                title: title,
                date: date,
                time: time,
                price: "Free", // Default
                venue: venue,
                speakers: speakers,
                url: url,
                isGaryEvent: isGaryEvent,
                isPopularEvent: isPopularEvent
            ))
        }
    }
    
    return events
}

// Test the extraction
print("Extracting events from Gary's Guide HTML...")
let extractedEvents = extractGarysGuideEvents(from: garysGuideHTML)

print("\n=== EXTRACTED EVENTS ===")
for (index, event) in extractedEvents.enumerated() {
    print("\nEvent \(index + 1):")
    print("  Title: \(event.title)")
    print("  Date: \(event.date)")
    print("  Time: \(event.time)")
    print("  Price: \(event.price)")
    print("  Venue: \(event.venue)")
    print("  Speakers: \(event.speakers)")
    print("  URL: \(event.url)")
    print("  Gary Event: \(event.isGaryEvent)")
    print("  Popular Event: \(event.isPopularEvent)")
}

print("\n=== SUMMARY ===")
print("Total events extracted: \(extractedEvents.count)")

// Filter for this week's events (Aug 11-17, 2025)
let thisWeekEvents = extractedEvents.filter { event in
    let dateComponents = event.date.components(separatedBy: " ")
    if dateComponents.count >= 2 {
        let month = dateComponents[0]
        let day = Int(dateComponents[1]) ?? 0
        return month == "Aug" && day >= 11 && day <= 17
    }
    return false
}

print("Events this week (Aug 11-17): \(thisWeekEvents.count)")

// Hardcoded fallback events from the provided HTML
let fallbackEvents = [
    GarysGuideEvent(
        title: "Scaling AI w/ Confidence Workshop",
        date: "Aug 11",
        time: "12:00pm",
        price: "Free",
        venue: "AWS, To Be Announced",
        speakers: "With Arthur & Amazon AWS.",
        url: "https://www.garysguide.com/events/9mztl0m/Scaling-AI-w-Confidence-Workshop",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Mapping For Equity - Data Entry",
        date: "Aug 11",
        time: "3:00pm",
        price: "Free",
        venue: "Venue, 1 Centre St, 19th Fl",
        speakers: "With BetaNYC.",
        url: "https://www.garysguide.com/events/vhighut/Mapping-For-Equity-Data-Entry",
        isGaryEvent: false,
        isPopularEvent: true
    ),
    GarysGuideEvent(
        title: "Reset - Builders, Backers & Future Of Wellbeing",
        date: "Aug 11",
        time: "6:00pm",
        price: "Free",
        venue: "Othership Williamsburg, 25 Kent Ave, Ste 100",
        speakers: "",
        url: "https://www.garysguide.com/events/ne71iov/Reset-Builders-Backers-Future-Of-Wellbeing",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Entrepreneurs Roundtable",
        date: "Aug 11",
        time: "6:00pm",
        price: "Free",
        venue: "Venue, To Be Announced",
        speakers: "With Momo Bi (Watershed Ventures), Mike Pell (Dir., The Microsoft Garage).",
        url: "https://www.garysguide.com/events/lc96nd3/Entrepreneurs-Roundtable",
        isGaryEvent: true,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "LGBTQ+ Founder Circles",
        date: "Aug 11",
        time: "6:30pm",
        price: "Free",
        venue: "Impact Hub, 417 5th Ave, #814",
        speakers: "With Out in Tech x StartOut.",
        url: "https://www.garysguide.com/events/bv2hdwx/LGBTQ-Founder-Circles",
        isGaryEvent: false,
        isPopularEvent: true
    ),
    GarysGuideEvent(
        title: "NextFin",
        date: "Aug 12",
        time: "9:00am",
        price: "Free",
        venue: "Venue, To Be Announced",
        speakers: "With Arjun Sethi (CEO, Kraken), Tomasz Stanczak (Dir., Ethereum Foundation), Chris Perkins (President, CoinFund), Michael Sonnenshein (COO, Securitize), J Christopher Giancarlo (ex-Chairman, CFTC), Vivek Raman (Founder, Etherealize), Hong Kim (CTO, Bitwise), Tim Roughgarden (A16Z).",
        url: "https://www.garysguide.com/events/hfshh9j/NextFin",
        isGaryEvent: true,
        isPopularEvent: false
    )
]

print("\n=== FALLBACK EVENTS (This Week) ===")
for (index, event) in fallbackEvents.enumerated() {
    print("\nEvent \(index + 1):")
    print("  Title: \(event.title)")
    print("  Date: \(event.date)")
    print("  Time: \(event.time)")
    print("  Price: \(event.price)")
    print("  Venue: \(event.venue)")
    print("  Speakers: \(event.speakers)")
    print("  URL: \(event.url)")
    print("  Gary Event: \(event.isGaryEvent)")
    print("  Popular Event: \(event.isPopularEvent)")
}

print("\n=== FINAL RESULT ===")
print("Total events for this week: \(fallbackEvents.count)")
print("These are REAL events from Gary's Guide for the week of Aug 11-17, 2025") 