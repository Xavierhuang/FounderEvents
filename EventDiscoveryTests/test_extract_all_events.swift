#!/usr/bin/env swift

import Foundation

// Comprehensive scraper to extract ALL events from Gary's Guide events page
print("=== EXTRACTING ALL EVENTS FROM GARY'S GUIDE ===")

// The actual HTML content from the Gary's Guide events page
let garysGuideEventsHTML = """
<!DOCTYPE html>
<html>
<head>
    <title>NYC Tech Events - GarysGuide</title>
</head>
<body>
    <div class="event-spotlight">
        <h2>EVENT SPOTLIGHT</h2>
        <div class="spotlight-event">
            <a href="http://gary.to/6u90122">Aug 06: NY AI Engineers - Aug Tech Talk w/ Google Gemini, Agentuity & Espresso Presenting</a>
            <p>With Claire Yin (Software Engineer ML, Google Gemini), Rick Blalock (Technical Founder, Agentuity), Espresso AI.</p>
        </div>
        <div class="spotlight-event">
            <a href="http://gary.to/v1rmdb2">Archery Expo 2025</a>
            <p>NYC's ultimate archery event. No zombies allowed! Try out bows, test your aim & gear up like a legend.</p>
        </div>
    </div>
    
    <div class="weekly-events">
        <h3>WEEK OF AUG 04</h3>
        
        <h4>Thursday, Aug 07</h4>
        <div class="event">
            <span class="time">12:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/7md1azk/Startup-Luncheon">Startup Luncheon</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Caroline Dell (Co-Founder/CEO, Goodword), Sarah Stein (CMO, VOESH), Alana Lomax (Co-Founder/CEO, UNTOLD).</span>
        </div>
        
        <div class="event">
            <span class="time">5:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/55ajswc/Startup-Mixer">Startup Mixer</a>
            <span class="venue">Sour Mouse, 110 Delancey St</span>
        </div>
        
        <div class="event">
            <span class="time">5:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/h5zj6us/Tech-Alley-First-Thursdays">Tech Alley First Thursdays</a>
            <span class="venue">Aquarelle, 47 Ave B</span>
        </div>
        
        <div class="event">
            <span class="time">5:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/fq2px2m/Tech-Alley-First-Thursdays">Tech Alley First Thursdays</a>
            <span class="venue">Venue, 47 Ave B</span>
        </div>
        
        <div class="event">
            <span class="time">5:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/xiatqxo/How-GTM-Teams-Are-Changing-In-2025">How GTM Teams Are Changing In 2025</a>
            <span class="venue">Clay HQ, 111 W 19th St</span>
            <span class="speakers">With Everett Berry (Head of GTM Engg, Clay), Patrick Spychalski (Co-Founder, The Kiln).</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/t3bqcye/NYC-Tech-Connect-Mixer">NYC Tech Connect Mixer</a>
            <span class="venue">Sugar Mouse, 47 3rd Ave</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/p1d9vmt/Liquid-Equity">Liquid Equity</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With founders, creators & investors.</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/1l6goa1/Cross-University-Fast-Pitch-Night">Cross-University Fast Pitch Night</a>
            <span class="venue">Next Jump, 512 W 22nd St</span>
            <span class="speakers">With Carly Bigi (Founder/CEO, Laws of Motion), Brian Hecht (ERA).</span>
        </div>
        
        <div class="event">
            <span class="time">6:30pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/s6xnst4/Product-Managers-Happy-Hour">Product Managers Happy Hour</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">7:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/d3svwtj/Long-Island-Technologists-Meetup">Long Island Technologists Meetup</a>
            <span class="venue">Flux Coffee, 211 Main St, Farmingdale</span>
            <span class="speakers">With Justin Abrams (CEO, Cause Of A Kind), Michael Rispoli (CTO, Cause Of A Kind).</span>
        </div>
        
        <div class="event">
            <span class="time">11:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/8vvu3ps/NY-Tech-Beer-Social">NY Tech & Beer Social</a>
            <span class="venue">Fools Gold, 145 E Houston St</span>
        </div>
        
        <h4>Friday, Aug 08</h4>
        <div class="event">
            <span class="time">8:30am</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/5gakac8/Founder-Breakfast">Founder Breakfast</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">8:30am</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/7793gf5/Founders-Funders-Getting-Ready-For-Fall-Fundraising">Founders+Funders - Getting Ready For Fall Fundraising</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Priyanka Jain (CEO, Evvy), Emma Silverman (TMV).</span>
        </div>
        
        <div class="event">
            <span class="time">9:00am</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/93vt5en/-Screening-Deep-Dive-Into-LLMs">[Screening] Deep Dive Into LLMs</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With LFC.DEV & Stifel.</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/ptfzxs4/Codeswitch">Codeswitch</a>
            <span class="venue">Kalye, 111 Rivington St</span>
        </div>
        
        <h4>Saturday, Aug 09</h4>
        <div class="event">
            <span class="time">8:30am</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/sb5ng0s/Hoka-Run-Club">Hoka Run Club</a>
            <span class="venue">HOKA Store Flatiron, 172 5th Ave</span>
            <span class="speakers">With Lime Social Club & Pitch & Run.</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/ao6xla1/NJ-Code-Coffee-Meetup">NJ Code & Coffee Meetup</a>
            <span class="venue">EqualSpace Tech & Innovation Campus, 550 Broad St, Newark</span>
        </div>
        
        <h4>Sunday, Aug 10</h4>
        <div class="event">
            <span class="time">1:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/esug82w/Verci-Gallery-Tech-Art-Show">Verci Gallery Tech Art Show</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">1:00pm</span>
            <span class="price">$35</span>
            <a href="https://www.garysguide.com/events/2my5utg/Startup-Friends-Tea-Stretch-Chill">Startup Friends - Tea, Stretch & Chill</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Mobius x Satori.</span>
        </div>
        
        <div class="event">
            <span class="time">4:30pm</span>
            <span class="price">$10</span>
            <a href="https://www.garysguide.com/events/a16uu4c/Code-Climb">Code & Climb</a>
            <span class="venue">MetroRock Bushwick, 321 Starr St, Brooklyn</span>
        </div>
    </div>
    
    <div class="weekly-events">
        <h3>WEEK OF AUG 11</h3>
        
        <h4>Monday, Aug 11</h4>
        <div class="event">
            <span class="time">12:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/9mztl0m/Scaling-AI-w-Confidence-Workshop">Scaling AI w/ Confidence Workshop</a>
            <span class="venue">AWS, To Be Announced</span>
            <span class="speakers">With Arthur & Amazon AWS.</span>
        </div>
        
        <div class="event">
            <span class="time">3:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/vhighut/Mapping-For-Equity-Data-Entry">Mapping For Equity - Data Entry</a>
            <span class="venue">Venue, 1 Centre St, 19th Fl</span>
            <span class="speakers">With BetaNYC.</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/ne71iov/Reset-Builders-Backers-Future-Of-Wellbeing">Reset - Builders, Backers & Future Of Wellbeing</a>
            <span class="venue">Othership Williamsburg, 25 Kent Ave, Ste 100</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/lc96nd3/Entrepreneurs-Roundtable">Entrepreneurs Roundtable</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Momo Bi (Watershed Ventures), Mike Pell (Dir., The Microsoft Garage).</span>
        </div>
        
        <div class="event">
            <span class="time">6:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/bv2hdwx/LGBTQ-Founder-Circles">LGBTQ+ Founder Circles</a>
            <span class="venue">Impact Hub, 417 5th Ave, #814</span>
            <span class="speakers">With Out in Tech x StartOut.</span>
        </div>
        
        <h4>Tuesday, Aug 12</h4>
        <div class="event">
            <span class="time">7:30am</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/jl4np8n/Miss-EmpowHer-IT-Girl-Walk">Miss EmpowHer IT Girl Walk</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">9:00am</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/hfshh9j/NextFin">NextFin</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Arjun Sethi (CEO, Kraken), Tomasz Stanczak (Dir., Ethereum Foundation), Chris Perkins (President, CoinFund), Michael Sonnenshein (COO, Securitize), J Christopher Giancarlo (ex-Chairman, CFTC), Vivek Raman (Founder, Etherealize), Hong Kim (CTO, Bitwise), Tim Roughgarden (A16Z).</span>
        </div>
        
        <div class="event">
            <span class="time">12:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/zl4834f/Office-Hours-For-Founders-Seed-To-Series-A">Office Hours For Founders - Seed To Series A</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Council Of Fractional CxOs.</span>
        </div>
        
        <div class="event">
            <span class="time">5:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/xe6cgu7/AI-ML-Conversations-Meetup-Production-Ready-GenAI">AI/ML Conversations Meetup - Production-Ready GenAI</a>
            <span class="venue">Venue, 11 W 19th St</span>
            <span class="speakers">With Alex Tsankov (ML Ops Enggr, Bloomberg).</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/v1smm2l/How-To-Win-A-1M-Pitch-Competition">How To Win A $1M Pitch Competition</a>
            <span class="venue">The Yard: Herald Sq, 106 W 32nd St</span>
            <span class="speakers">Wth Nyamitse-Calvin Mahinda (Founder/CEO, Vital Audio).</span>
        </div>
        
        <div class="event">
            <span class="time">6:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/lml0h1u/DesciNYC-Cell-Metabolism">DesciNYC - Cell Metabolism</a>
            <span class="venue">Venue, To Be Announced</span>
            <span class="speakers">With Tim Kenny (Molecular & Cellular Biologist).</span>
        </div>
        
        <div class="event">
            <span class="time">7:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/uqmimvx/Connections-Capital-Meetup">Connections & Capital Meetup</a>
            <span class="venue">Pubkey, 85 Washington Pl</span>
            <span class="speakers">With Fortress & Next Layer Capital.</span>
        </div>
        
        <h4>Wednesday, Aug 13</h4>
        <div class="event">
            <span class="time">9:00am</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/6gx55rz/Startup-Lean-Coffee">Startup Lean Coffee</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">10:00am</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/1gnn2ia/Ethereum-Research-Funding-Forum">Ethereum Research Funding Forum</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">5:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/vs82p36/Elastic-PyData-Meetup">Elastic & PyData Meetup</a>
            <span class="venue">Elastic HQ, 1250 Broadway</span>
            <span class="speakers">With Hariharan Ragothaman (S/w Enggr, AMD).</span>
        </div>
        
        <div class="event">
            <span class="time">5:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/euo3tqs/Circle-Dev-Summit">Circle Dev Summit</a>
            <span class="venue">1WTC, 285 Fulton St</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <a href="https://www.garysguide.com/events/4vuw3gx/The-Million-Dollar-Mixer">The Million Dollar Mixer</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">$15</span>
            <a href="https://www.garysguide.com/events/gtj4n6c/AI-Tech-Mixer">AI & Tech Mixer</a>
            <span class="venue">Whiskey Cellar, 77 E 7th St</span>
        </div>
        
        <h4>Thursday, Aug 14</h4>
        <div class="event">
            <span class="time">9:30am</span>
            <span class="price">$99</span>
            <a href="https://www.garysguide.com/events/r8a23pt/Pragma-Founder-Talks">Pragma Founder Talks</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">6:00pm</span>
            <span class="price">Free</span>
            <span class="badge">Popular Event</span>
            <a href="https://www.garysguide.com/events/6ludp2w/ETHGlobal-Happy-Hour">ETHGlobal Happy Hour</a>
            <span class="venue">Venue, To Be Announced</span>
        </div>
        
        <div class="event">
            <span class="time">6:30pm</span>
            <span class="price">Free</span>
            <span class="badge">Gary Event</span>
            <a href="https://www.garysguide.com/events/ghf0qa5/Hardware-Meetup-Space-Tech">Hardware Meetup - Space Tech</a>
            <span class="venue">Adafruit at Industry City, To Be Announced</span>
            <span class="speakers">With Limor Fried (Founder, Adafruit), Muhammad Hunain (Founder/CEO, Melagen Labs), Ethan Barajas (CEO, Icarus Robotics).</span>
        </div>
        
        <div class="event">
            <span class="time">6:30pm</span>
            <span class="price">$10</span>
            <a href="https://www.garysguide.com/events/2z0t5x0/Founders-Investors-Operators-Mixer">Founders, Investors & Operators Mixer</a>
            <span class="venue">Venue, To Be Announced</span>
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
    let week: String
}

func extractAllEvents(from html: String) -> [GarysGuideEvent] {
    var events: [GarysGuideEvent] = []
    
    // Split HTML into lines for easier parsing
    let lines = html.components(separatedBy: .newlines)
    
    var currentWeek = ""
    var currentDate = ""
    var currentTime = ""
    var currentPrice = "Free"
    var currentTitle = ""
    var currentUrl = ""
    var currentVenue = ""
    var currentSpeakers = ""
    var isGaryEvent = false
    var isPopularEvent = false
    
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract week
        if trimmedLine.contains("WEEK OF") {
            if let weekStart = trimmedLine.range(of: "WEEK OF "),
               let weekEnd = trimmedLine.range(of: "</h3>", range: weekStart.upperBound..<trimmedLine.endIndex) {
                currentWeek = String(trimmedLine[weekStart.upperBound..<weekEnd.lowerBound])
            }
        }
        
        // Extract date
        if trimmedLine.contains("h4>") && trimmedLine.contains("</h4>") {
            if let dateStart = trimmedLine.range(of: ">"),
               let dateEnd = trimmedLine.range(of: "</h4>", range: dateStart.upperBound..<trimmedLine.endIndex) {
                currentDate = String(trimmedLine[dateStart.upperBound..<dateEnd.lowerBound])
            }
        }
        
        // Extract time
        if trimmedLine.contains("class=\"time\">") {
            if let timeStart = trimmedLine.range(of: "class=\"time\">"),
               let timeEnd = trimmedLine.range(of: "</span>", range: timeStart.upperBound..<trimmedLine.endIndex) {
                currentTime = String(trimmedLine[timeStart.upperBound..<timeEnd.lowerBound])
            }
        }
        
        // Extract price
        if trimmedLine.contains("class=\"price\">") {
            if let priceStart = trimmedLine.range(of: "class=\"price\">"),
               let priceEnd = trimmedLine.range(of: "</span>", range: priceStart.upperBound..<trimmedLine.endIndex) {
                currentPrice = String(trimmedLine[priceStart.upperBound..<priceEnd.lowerBound])
            }
        }
        
        // Extract badges
        if trimmedLine.contains("Gary Event") {
            isGaryEvent = true
        } else if trimmedLine.contains("Popular Event") {
            isPopularEvent = true
        }
        
        // Extract event title and URL
        if trimmedLine.contains("href=\"https://www.garysguide.com/events/") {
            if let hrefStart = trimmedLine.range(of: "href=\""),
               let hrefEnd = trimmedLine.range(of: "\"", range: hrefStart.upperBound..<trimmedLine.endIndex),
               let titleStart = trimmedLine.range(of: ">"),
               let titleEnd = trimmedLine.range(of: "</a>", range: titleStart.upperBound..<trimmedLine.endIndex) {
                
                currentUrl = String(trimmedLine[hrefStart.upperBound..<hrefEnd.lowerBound])
                currentTitle = String(trimmedLine[titleStart.upperBound..<titleEnd.lowerBound])
            }
        }
        
        // Extract venue
        if trimmedLine.contains("class=\"venue\">") {
            if let venueStart = trimmedLine.range(of: "class=\"venue\">"),
               let venueEnd = trimmedLine.range(of: "</span>", range: venueStart.upperBound..<trimmedLine.endIndex) {
                currentVenue = String(trimmedLine[venueStart.upperBound..<venueEnd.lowerBound])
            }
        }
        
        // Extract speakers
        if trimmedLine.contains("class=\"speakers\">") {
            if let speakersStart = trimmedLine.range(of: "class=\"speakers\">"),
               let speakersEnd = trimmedLine.range(of: "</span>", range: speakersStart.upperBound..<trimmedLine.endIndex) {
                currentSpeakers = String(trimmedLine[speakersStart.upperBound..<speakersEnd.lowerBound])
            }
        }
        
        // When we have all the pieces, create the event
        if !currentTitle.isEmpty && !currentTime.isEmpty {
            events.append(GarysGuideEvent(
                title: currentTitle,
                date: currentDate,
                time: currentTime,
                price: currentPrice,
                venue: currentVenue.isEmpty ? "TBD" : currentVenue,
                speakers: currentSpeakers,
                url: currentUrl,
                isGaryEvent: isGaryEvent,
                isPopularEvent: isPopularEvent,
                week: currentWeek
            ))
            
            // Reset for next event
            currentTitle = ""
            currentUrl = ""
            currentVenue = ""
            currentSpeakers = ""
            isGaryEvent = false
            isPopularEvent = false
        }
    }
    
    return events
}

// Extract all events
print("Extracting ALL events from Gary's Guide events page...")
let allEvents = extractAllEvents(from: garysGuideEventsHTML)

print("\n=== ALL EXTRACTED EVENTS ===")
for (index, event) in allEvents.enumerated() {
    print("\nEvent \(index + 1): \(event.title)")
    print("  Week: \(event.week)")
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
print("Total events extracted: \(allEvents.count)")

// Count by week
let weekOfAug04 = allEvents.filter { $0.week.contains("AUG 04") }
let weekOfAug11 = allEvents.filter { $0.week.contains("AUG 11") }

print("Week of Aug 04: \(weekOfAug04.count) events")
print("Week of Aug 11: \(weekOfAug11.count) events")

// Count by type
let garyEvents = allEvents.filter { $0.isGaryEvent }
let popularEvents = allEvents.filter { $0.isPopularEvent }
let regularEvents = allEvents.filter { !$0.isGaryEvent && !$0.isPopularEvent }

print("Gary Events: \(garyEvents.count)")
print("Popular Events: \(popularEvents.count)")
print("Regular Events: \(regularEvents.count)")

// Count by price
let freeEvents = allEvents.filter { $0.price == "Free" }
let paidEvents = allEvents.filter { $0.price != "Free" }

print("Free Events: \(freeEvents.count)")
print("Paid Events: \(paidEvents.count)")

print("\n=== PAID EVENTS ===")
for event in paidEvents {
    print("\(event.title): \(event.price)")
}

print("\n✅ Successfully extracted \(allEvents.count) events from Gary's Guide!")
print("Events span multiple weeks and include both free and paid events") 