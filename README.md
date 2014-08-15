# TAP iPad
Welcome to the TAP iPad app!

This documentation will be more useful with the benefit of context. The TAP iPad app was first developed at the IMA for use as a kiosk-type app for in-gallery use during marquee exhibitions.

Because of this stationary-usage focus, while this TAP implementation is most definitely capable of loading its content from the network (via the TourMLEndpoint property in the TAPConfig plist), it is not optimized for that scenario, and loading content on first-launch is a non-trivial bottleneck. This operation could, however, easily be pushed to another thread, we just haven't done this here because the UI implications of doing so have not yet been addressed.

With that out of the way, let's talk about what you can do with this thing. The app has five basic view types, which I will now list for you!

## Timeline "Stop" View
The timeline view is, more or less, what it sounds like. It maps a series of event stops contained by a stop group to events mapped out on a horizontally scrolling timeline. The structure of the underlying data this view expects looks like this:
- Stop Group
	- Event Stops

## Themes "Stop" View
This view presents a grid of an arbitrary number of, you guessed it 'themes,' which then allow the user to drill into a group of stops containing content around that theme.
- Stop Group
	- Stop Group(s)
		- Image/Video/Audio Stop(s)

## Theme "Stop" View
This is just the singular view that the themes view drills into, but which can also be used as a top-level view.
- Stop Group
	- Image/Video/Audio Stops

## Generic Web Container View
This is a container for loading LOCAL web content into a UIWebView. It has no backing TourML content, just what you put in the 


These views are backed by TourML data (in our case generated using the TAP CMS) corresponding to the views in the structures described above.

## Areas For Improvement in this codebase
Coupling with tourml-parse-objc

@TODO what is the interview view?