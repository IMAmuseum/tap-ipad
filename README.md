# TAP iPad
Welcome to the TAP iPad app!

This documentation will be more useful with the benefit of context. The TAP iPad app was first developed at the IMA for use as a kiosk-type app for in-gallery use during marquee exhibitions. It has three basic view types, which I will now list for you!

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


These views are backed by TourML data (in our case generated using the TAP CMS) corresponding to the views in the structures described above.

@TODO what is the interview view?