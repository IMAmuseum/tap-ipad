# TAP iPad

Welcome to the TAP iPad app!

This documentation will be more useful with the benefit of context. If you already know what TAP is, well done, clearly you are a handsome/beautiful individual with excellent taste. If you do not, [read more about it](http://tapintomuseums.org) and join the ranks of Those In The Know.

As for this app, it was first developed at the IMA Lab by former Lab employee [Daniel Cervantes](https://www.linkedin.com/profile/view?id=67166968), for use as a kiosk-type app for in-gallery use during exhibitions. It consumes TAP data in the TourML format, either in a local exported bundle, or by loading it over the network, and then presents the data in a few different pre-defined view types.

Now let's talk about those view types.

## Timeline "Stop" View
The timeline view is, more or less, what it sounds like. It maps a series of event stops contained by a stop group to events mapped out on a horizontally scrolling timeline. The structure of the underlying data this view expects looks like this:
### Backing data structure for this view
- Stop Group
	- Event Stops

## Themes "Stop" View
This view presents a grid of an arbitrary number of, you guessed it 'themes,' which then allow the user to drill into a group of stops containing content around that theme.
### Backing data structure for this view
- Stop Group
	- Stop Group(s)
		- Image/Video/Audio Stop(s)

## Theme "Stop" View
This is just the singular view that the themes view drills into, but which can also be used as a top-level view.
### Backing data structure for this view
- Stop Group
	- Image/Video/Audio Stops

## Interview Stop
Rename this, get one into the app?
### Backing data structure for this view

## Generic Web Container View
This is a container for loading LOCAL web content into a UIWebView. It has no backing TourML content, just what you put in the 





## Areas For Improvement in this codebase
Coupling with tourml-parse-objc
Async data fetch that doesn't block the UI? (what would this ui even do with that?)

@TODO what is the interview view?