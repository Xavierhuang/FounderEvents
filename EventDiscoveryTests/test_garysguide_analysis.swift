#!/usr/bin/env swift

import Foundation

// Analysis of Gary's Guide HTML structure
print("=== GARY'S GUIDE HTML ANALYSIS ===")

// Sample HTML content from Gary's Guide
let garysGuideHTML = """
<!DOCTYPE html>
<html>
<head>
    <title>NYC Tech Events - GarysGuide | The #1 Resource for NYC Tech</title>
    <!-- ... head content ... -->
</head>
<body>
    <!-- ... navigation ... -->
    
    <!-- EVENT SPOTLIGHT SECTION -->
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
    
    <!-- WEEKLY EVENTS SECTION -->
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
            </table>
        </div>
    </div>
</body>
</html>
"""

print("=== HTML STRUCTURE ANALYSIS ===")

// Key patterns identified:
print("1. EVENT SPOTLIGHT SECTION:")
print("   - Located in <div class='fbox'> with padding:15px")
print("   - Events have <font class='fblack'> with <b> tags for titles")
print("   - Links use href='http://gary.to/...' format")
print("   - Images use src='https://s3.amazonaws.com/garysguide/...'")

print("\n2. WEEKLY EVENTS SECTION:")
print("   - Organized by day: <font class='fblack'><b>Thursday, Aug 07</b></font>")
print("   - Time format: <b>Aug 07</b><br/>12:00pm")
print("   - Price: Free, $35, etc.")
print("   - Event details in nested tables with <font class='ftitle'> for names")
print("   - Venue info in <font class='fdescription'>")
print("   - Speakers in <font class='fgray'>")

print("\n3. EVENT EXTRACTION PATTERNS:")
print("   - Event titles: <font class='ftitle'><a alt='...' href='...'><b>Title</b></a>")
print("   - Event URLs: href='https://www.garysguide.com/events/...'")
print("   - Venues: <font class='fdescription'><br/><b>Venue Name</b>, Address")
print("   - Speakers: <font class='fgray'>With Speaker Name <i>(Title, Company)</i>")
print("   - Special indicators: <img title='Gary Event' alt='Gary Event' width='30' src='...'/>")

print("\n4. DATE AND TIME PATTERNS:")
print("   - Day headers: <font class='fblack'><b>Day, Month DD</b></font>")
print("   - Time format: <b>Month DD</b><br/>HH:MMam/pm")
print("   - Week sections: <font class='fboxtitle'>WEEK OF MONTH DD</font>")

print("\n=== EXTRACTION STRATEGY ===")
print("1. Find all <div class='fbox'> elements")
print("2. Look for <font class='fblack'><b>Day, Month DD</b></font> for day headers")
print("3. Extract time from <b>Month DD</b><br/>HH:MMam/pm")
print("4. Extract price from the price column")
print("5. Extract event title from <font class='ftitle'><a alt='...' href='...'><b>Title</b></a>")
print("6. Extract venue from <font class='fdescription'><br/><b>Venue</b>, Address")
print("7. Extract speakers from <font class='fgray'>With Speaker Name <i>(Title, Company)</i>")
print("8. Extract event URL from href='https://www.garysguide.com/events/...'")

print("\n=== IMPLEMENTATION PLAN ===")
print("1. Use regex patterns to find event sections")
print("2. Parse HTML structure systematically")
print("3. Handle both 'Event Spotlight' and 'Weekly Events' sections")
print("4. Filter for current week events")
print("5. Extract all event details into structured data") 