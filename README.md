# RAT 
*Please note: I am publicising this more than a decade after I made it so details may be fuzzy and I know there are a lot of things I would do differently, for example the code is naieve and messy, different versions are in the same repo. "So why are you sharing it then Ed?" I hear you cry. well, I think the concept is interesting and may inspire modernised solutions to similar challenges.*

## Intro
I built this device to solve a problem. Wharehouse staff working in inbound quality control who were largely not tech savvy had heen manually testing the routers by following a standard operating proceedure but the issue was brought to my attention because each device was taking 50min to test and so sampling targets were being routinely missed.

## Process 
Initially, I reviewed the standard operating procedure. There were actions which repeated what was essentially another test that had already been carried out.

I then met with the team and was walked through what they do. Next, I rewrote the standard operating procedure with the target group in mind, and the arranged a half-day introductory training for the new process, taking time to explain what each step was doing and answering questions until each member of the team and gauging their responses to the changes, which by the end of the session were unamimously positive.

These changes took the test time down from 50min per device to between 10 and 15min. However, a little while after, new designs of devices including dual band wifi made the tests more complex, and rather than just taking more time, it was becoming beyond what could reasonably be expected of non technical workers.

### Enter the RAT!

The Supply Chain director asked me if it was possible to create a simple device where you just press a button and run the tests. He felt it was a big task and asked me to mull it over. On a weekend I was trying some of the concepts needed to make it work, and had a go and a couple of very simple tests as a proof of concept. I made this PoC using a bare bones Pi 2 with a protoboard for LED's as Id always envisiged that this would be a headless embeded device.

With autodetect added I had started building out the solution the Supply Chain Director had asked, only I didn't need the button!



## RouterAcceptanceTester

The RAT is a Router Acceptance Tester which can assess the core functionality of a broadband router, by checking the following:
- The presence of the router:
  If the router is present and ping responds on the ethernet port, the dwvice automatically detects the router.
  If the router is unplugged or fails, the RAT returns to a 'waiting' loop, otherwise the tests continue.
- The gateway is up:
  Check that a known web resource is present using a basic ping
  If so, update the date and time from NTP
- That the embedded DNS server works as expected:
  Reach a web resource using a url
- The the login credentials are as we expect:
  Log into the router
  naviate to the relevant page, and scrape the router's Mac Address, SSID, and wifi password
- Test the 2.4ghz WiFi:
  Set the ethernet port on the RAT to down, then bring up the 2.4ghz wifi interface and run the same DNS lookup 
- Test 5ghz WiFi:
  Take the 2.4ghz interface down, bring the 5ghz interface up, and repeat the tests
- Report:
  There are light sequences which actually represent each step of the test (and the waiting loop) and at this stage, if all
  tests pass, you will het flashing green lights, otherwise, amber lights if a test failed. if the router is dead, it wont be    detected, otherwise the date, time, MAC Address and 'pass' or the details of the fail to an SFTP server (imcomplete)
- Re-enter the waiting loop as soon as the router is no longer responding i.e. unplugged or powered off

## Platform

This code was originally, after the initial development board, ran on a Beaglebone Black with an LED board with 2 x Red, 2 x Amber, and 4 x Green LEDs. Some tweaking with the resistors may be needed to ensure equal brightness in normal lighting settings. 

This could easily be recreated on a beefy arduino now and this would all be C++, but at the time, the only way to go was to Raspberry Pi or, the final choice, the Beaglebone Black. 

The code was run on Arch Linux with a very stripped down kernel in order to make the device boot in a few seconds. As the pnly feedback was the LED's there is an LED sequence that tells you the device is booting and when it is ready to start testing. This was to prevent the intended users fromm falsely thinking boot had failed and unplugging it and trying again which could potentially corrupt the SD card.

At the time the Pi had a full size SD card which protruded whereas the Beaglebone Black had a micro SD card which was more difficult to tamper with or damage. I explored this when the original Pi + protoboard was in transport and slight pressure on the protruding SD card caused the Pi to fail to boot until the slot was resoldered. The Beaglebone had a smaller footprint and much nicer case options (pre-affordable 3D printing)

## Further work for this project repo: Ill share a video of the RAT doing a test and anything else which might help anyone wanting to create a clone to start working with. 
