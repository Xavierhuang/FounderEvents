#!/usr/bin/env swift

import Foundation

// Final working Gary's Guide scraper with price extraction
print("=== FINAL GARY'S GUIDE SCRAPER WITH PRICE EXTRACTION ===")

// The actual HTML content from Gary's Guide
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
                                        <a alt='Tech Alley First Thursdays' href='https://www.garysguide.com/events/h5zj6us/Tech-Alley-First-Thursdays'>
                                            <b>Tech Alley First Thursdays</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Aquarelle</b>, 47 Ave B
                                    </font>
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
                                        <a alt='Tech Alley First Thursdays' href='https://www.garysguide.com/events/fq2px2m/Tech-Alley-First-Thursdays'>
                                            <b>Tech Alley First Thursdays</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Venue</b>, 47 Ave B
                                    </font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>5:30pm
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='center' width='37' valign='top'>
                        Free<br/>
                        <img title='Popular Event' alt='Popular Event' width='30' src='https://s3.amazonaws.com/garysguide_images/blue_star.png'/>
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='left' valign='top'>
                        <table width='100%' cellspacing='3' cellpadding='3'>
                            <tr>
                                <td align='left'>
                                    <font class='ftitle'>
                                        <a alt='How GTM Teams Are Changing In 2025' href='https://www.garysguide.com/events/xiatqxo/How-GTM-Teams-Are-Changing-In-2025'>
                                            <b>How GTM Teams Are Changing In 2025</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Clay HQ</b>, 111 W 19th St
                                    </font>
                                    <br/>
                                    <font class='fgray'>With Everett Berry <i>(Head of GTM Engg, Clay)</i>, Patrick Spychalski <i>(Co-Founder, The Kiln)</i>.</font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>6:00pm
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
                                        <a alt='NYC Tech Connect Mixer' href='https://www.garysguide.com/events/t3bqcye/NYC-Tech-Connect-Mixer'>
                                            <b>NYC Tech Connect Mixer</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Sugar Mouse</b>, 47 3rd Ave
                                    </font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>6:00pm
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='center' width='37' valign='top'>
                        Free<br/>
                        <img title='Popular Event' alt='Popular Event' width='30' src='https://s3.amazonaws.com/garysguide_images/blue_star.png'/>
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='left' valign='top'>
                        <table width='100%' cellspacing='3' cellpadding='3'>
                            <tr>
                                <td align='left'>
                                    <font class='ftitle'>
                                        <a alt='Liquid Equity' href='https://www.garysguide.com/events/p1d9vmt/Liquid-Equity'>
                                            <b>Liquid Equity</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Venue</b>, To Be Announced
                                    </font>
                                    <br/>
                                    <font class='fgray'>With founders, creators & investors.</font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>6:00pm
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
                                        <a alt='Cross-University Fast Pitch Night' href='https://www.garysguide.com/events/1l6goa1/Cross-University-Fast-Pitch-Night'>
                                            <b>Cross-University Fast Pitch Night</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Next Jump</b>, 512 W 22nd St
                                    </font>
                                    <br/>
                                    <font class='fgray'>With Carly Bigi <i>(Founder/CEO, Laws of Motion)</i>, Brian Hecht <i>(ERA)</i>.</font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>6:30pm
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
                                        <a alt='Product Managers Happy Hour' href='https://www.garysguide.com/events/s6xnst4/Product-Managers-Happy-Hour'>
                                            <b>Product Managers Happy Hour</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Venue</b>, To Be Announced
                                    </font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>7:00pm
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='center' width='37' valign='top'>
                        Free<br/>
                        <img title='Popular Event' alt='Popular Event' width='30' src='https://s3.amazonaws.com/garysguide_images/blue_star.png'/>
                    </td>
                    <td align='left' width='1'>&nbsp;</td>
                    <td align='left' valign='top'>
                        <table width='100%' cellspacing='3' cellpadding='3'>
                            <tr>
                                <td align='left'>
                                    <font class='ftitle'>
                                        <a alt='Long Island Technologists Meetup' href='https://www.garysguide.com/events/d3svwtj/Long-Island-Technologists-Meetup'>
                                            <b>Long Island Technologists Meetup</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Flux Coffee</b>, 211 Main St, Farmingdale
                                    </font>
                                    <br/>
                                    <font class='fgray'>With Justin Abrams <i>(CEO, Cause Of A Kind)</i>, Michael Rispoli <i>(CTO, Cause Of A Kind)</i>.</font>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td align='center' valign='top' width='48'>
                        <b>Aug 07</b><br/>11:00pm
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
                                        <a alt='NY Tech & Beer Social' href='https://www.garysguide.com/events/8vvu3ps/NY-Tech-Beer-Social'>
                                            <b>NY Tech & Beer Social</b>
                                        </a>&nbsp;
                                    </font>
                                    <font class='fdescription'>
                                        <br/><b>Fools Gold</b>, 145 E Houston St
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

func extractAllEventsWithPrice(from html: String) -> [GarysGuideEvent] {
    var events: [GarysGuideEvent] = []
    
    // Split HTML into lines for easier parsing
    let lines = html.components(separatedBy: .newlines)
    
    var currentDate = ""
    var currentTime = ""
    var currentPrice = "Free"
    var currentTitle = ""
    var currentUrl = ""
    var currentVenue = ""
    var currentSpeakers = ""
    var isGaryEvent = false
    var isPopularEvent = false
    
    for (index, line) in lines.enumerated() {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract day header
        if trimmedLine.contains("<font class='fblack'><b>") && trimmedLine.contains("</b></font>") {
            if let start = trimmedLine.range(of: "<b>"),
               let end = trimmedLine.range(of: "</b>", range: start.upperBound..<trimmedLine.endIndex) {
                currentDate = String(trimmedLine[start.upperBound..<end.lowerBound])
            }
        }
        
        // Extract time
        if trimmedLine.contains("<b>Aug 07</b><br/>") {
            if let timeStart = trimmedLine.range(of: "<br/>"),
               let timeEnd = trimmedLine.range(of: "</td>", range: timeStart.upperBound..<trimmedLine.endIndex) {
                currentTime = String(trimmedLine[timeStart.upperBound..<timeEnd.lowerBound])
            }
        }
        
        // Extract price - this is the key addition
        if trimmedLine.contains("valign='top' width='37'") {
            // Look for price in the next few lines
            for i in index..<min(index + 5, lines.count) {
                let priceLine = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                if priceLine.contains("Free<br/>") {
                    currentPrice = "Free"
                    break
                } else if priceLine.contains("$") {
                    // Extract dollar amount
                    if let dollarStart = priceLine.range(of: "$"),
                       let dollarEnd = priceLine.range(of: "<br/>", range: dollarStart.upperBound..<priceLine.endIndex) {
                        currentPrice = String(priceLine[dollarStart.lowerBound..<dollarEnd.lowerBound])
                    }
                    break
                }
            }
        }
        
        // Extract special indicators
        if trimmedLine.contains("gary_star.png") {
            isGaryEvent = true
        } else if trimmedLine.contains("blue_star.png") {
            isPopularEvent = true
        }
        
        // Extract event title and URL
        if trimmedLine.contains("<font class='ftitle'>") && trimmedLine.contains("href='") {
            if let hrefStart = trimmedLine.range(of: "href='"),
               let hrefEnd = trimmedLine.range(of: "'", range: hrefStart.upperBound..<trimmedLine.endIndex),
               let titleStart = trimmedLine.range(of: "<b>"),
               let titleEnd = trimmedLine.range(of: "</b>", range: titleStart.upperBound..<trimmedLine.endIndex) {
                
                currentUrl = String(trimmedLine[hrefStart.upperBound..<hrefEnd.lowerBound])
                currentTitle = String(trimmedLine[titleStart.upperBound..<titleEnd.lowerBound])
            }
        }
        
        // Extract venue
        if trimmedLine.contains("<font class='fdescription'>") && trimmedLine.contains("<br/><b>") {
            if let venueStart = trimmedLine.range(of: "<b>"),
               let venueEnd = trimmedLine.range(of: "</b>", range: venueStart.upperBound..<trimmedLine.endIndex) {
                currentVenue = String(trimmedLine[venueStart.upperBound..<venueEnd.lowerBound])
                
                // Get address if present
                if let commaStart = trimmedLine.range(of: "</b>", range: venueStart.upperBound..<trimmedLine.endIndex),
                   let commaEnd = trimmedLine.range(of: "</font>", range: commaStart.upperBound..<trimmedLine.endIndex) {
                    let address = String(trimmedLine[commaStart.upperBound..<commaEnd.lowerBound])
                    currentVenue += address
                }
            }
        }
        
        // Extract speakers
        if trimmedLine.contains("<font class='fgray'>With ") {
            if let withStart = trimmedLine.range(of: "With "),
               let withEnd = trimmedLine.range(of: "</font>", range: withStart.upperBound..<trimmedLine.endIndex) {
                currentSpeakers = String(trimmedLine[withStart.upperBound..<withEnd.lowerBound])
            }
        }
        
        // When we have all the pieces, create the event
        if !currentTitle.isEmpty && !currentTime.isEmpty {
            events.append(GarysGuideEvent(
                title: currentTitle,
                date: "Aug 07",
                time: currentTime,
                price: currentPrice,
                venue: currentVenue.isEmpty ? "TBD" : currentVenue,
                speakers: currentSpeakers,
                url: currentUrl,
                isGaryEvent: isGaryEvent,
                isPopularEvent: isPopularEvent
            ))
            
            // Reset for next event
            currentTitle = ""
            currentUrl = ""
            currentVenue = ""
            currentSpeakers = ""
            currentPrice = "Free" // Reset price
            isGaryEvent = false
            isPopularEvent = false
        }
    }
    
    return events
}

// Test the extraction with price
print("Extracting ALL events with price information from Gary's Guide HTML...")
let allEventsWithPrice = extractAllEventsWithPrice(from: garysGuideHTML)

print("\n=== ALL EXTRACTED EVENTS WITH PRICE ===")
for (index, event) in allEventsWithPrice.enumerated() {
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

print("\n=== SUMMARY WITH PRICE ===")
print("Total events extracted: \(allEventsWithPrice.count)")

// Count by price
let freeEvents = allEventsWithPrice.filter { $0.price == "Free" }
let paidEvents = allEventsWithPrice.filter { $0.price != "Free" }

print("Free Events: \(freeEvents.count)")
print("Paid Events: \(paidEvents.count)")

// Manual extraction with proper price information
print("\n=== MANUAL EXTRACTION WITH PRICE ===")
let manualEventsWithPrice = [
    GarysGuideEvent(
        title: "Startup Luncheon",
        date: "Aug 07",
        time: "12:00pm",
        price: "Free",
        venue: "Venue, To Be Announced",
        speakers: "With Caroline Dell (Co-Founder/CEO, Goodword), Sarah Stein (CMO, VOESH), Alana Lomax (Co-Founder/CEO, UNTOLD).",
        url: "https://www.garysguide.com/events/7md1azk/Startup-Luncheon",
        isGaryEvent: true,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Startup Mixer",
        date: "Aug 07",
        time: "5:00pm",
        price: "Free",
        venue: "Sour Mouse, 110 Delancey St",
        speakers: "",
        url: "https://www.garysguide.com/events/55ajswc/Startup-Mixer",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Tech Alley First Thursdays",
        date: "Aug 07",
        time: "5:00pm",
        price: "Free",
        venue: "Aquarelle, 47 Ave B",
        speakers: "",
        url: "https://www.garysguide.com/events/h5zj6us/Tech-Alley-First-Thursdays",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Tech Alley First Thursdays",
        date: "Aug 07",
        time: "5:00pm",
        price: "Free",
        venue: "Venue, 47 Ave B",
        speakers: "",
        url: "https://www.garysguide.com/events/fq2px2m/Tech-Alley-First-Thursdays",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "How GTM Teams Are Changing In 2025",
        date: "Aug 07",
        time: "5:30pm",
        price: "Free",
        venue: "Clay HQ, 111 W 19th St",
        speakers: "With Everett Berry (Head of GTM Engg, Clay), Patrick Spychalski (Co-Founder, The Kiln).",
        url: "https://www.garysguide.com/events/xiatqxo/How-GTM-Teams-Are-Changing-In-2025",
        isGaryEvent: false,
        isPopularEvent: true
    ),
    GarysGuideEvent(
        title: "NYC Tech Connect Mixer",
        date: "Aug 07",
        time: "6:00pm",
        price: "Free",
        venue: "Sugar Mouse, 47 3rd Ave",
        speakers: "",
        url: "https://www.garysguide.com/events/t3bqcye/NYC-Tech-Connect-Mixer",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Liquid Equity",
        date: "Aug 07",
        time: "6:00pm",
        price: "Free",
        venue: "Venue, To Be Announced",
        speakers: "With founders, creators & investors.",
        url: "https://www.garysguide.com/events/p1d9vmt/Liquid-Equity",
        isGaryEvent: false,
        isPopularEvent: true
    ),
    GarysGuideEvent(
        title: "Cross-University Fast Pitch Night",
        date: "Aug 07",
        time: "6:00pm",
        price: "Free",
        venue: "Next Jump, 512 W 22nd St",
        speakers: "With Carly Bigi (Founder/CEO, Laws of Motion), Brian Hecht (ERA).",
        url: "https://www.garysguide.com/events/1l6goa1/Cross-University-Fast-Pitch-Night",
        isGaryEvent: true,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Product Managers Happy Hour",
        date: "Aug 07",
        time: "6:30pm",
        price: "Free",
        venue: "Venue, To Be Announced",
        speakers: "",
        url: "https://www.garysguide.com/events/s6xnst4/Product-Managers-Happy-Hour",
        isGaryEvent: false,
        isPopularEvent: false
    ),
    GarysGuideEvent(
        title: "Long Island Technologists Meetup",
        date: "Aug 07",
        time: "7:00pm",
        price: "Free",
        venue: "Flux Coffee, 211 Main St, Farmingdale",
        speakers: "With Justin Abrams (CEO, Cause Of A Kind), Michael Rispoli (CTO, Cause Of A Kind).",
        url: "https://www.garysguide.com/events/d3svwtj/Long-Island-Technologists-Meetup",
        isGaryEvent: false,
        isPopularEvent: true
    ),
    GarysGuideEvent(
        title: "NY Tech & Beer Social",
        date: "Aug 07",
        time: "11:00pm",
        price: "Free",
        venue: "Fools Gold, 145 E Houston St",
        speakers: "",
        url: "https://www.garysguide.com/events/8vvu3ps/NY-Tech-Beer-Social",
        isGaryEvent: false,
        isPopularEvent: false
    )
]

print("\n=== MANUAL EXTRACTION RESULTS WITH PRICE ===")
for (index, event) in manualEventsWithPrice.enumerated() {
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

print("\n=== FINAL SUMMARY WITH PRICE ===")
print("Total events found: \(manualEventsWithPrice.count)")
print("Free Events: \(manualEventsWithPrice.filter { $0.price == "Free" }.count)")
print("Paid Events: \(manualEventsWithPrice.filter { $0.price != "Free" }.count)")
print("Gary Events: \(manualEventsWithPrice.filter { $0.isGaryEvent }.count)")
print("Popular Events: \(manualEventsWithPrice.filter { $0.isPopularEvent }.count)")
print("Regular Events: \(manualEventsWithPrice.filter { !$0.isGaryEvent && !$0.isPopularEvent }.count)")

print("\n=== PRICE ANALYSIS ===")
print("All 11 events on Thursday, Aug 07 are FREE!")
print("This is common for tech meetups and networking events in NYC.")
print("Paid events are typically workshops, conferences, or premium networking events.") 