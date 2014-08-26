# TAP iPad

Welcome to the TAP iPad app!

This documentation will be more useful with the benefit of context. If you already know what TAP is, well done, clearly you are a handsome/beautiful individual with excellent taste. If you do not, [read more about it](http://tapintomuseums.org) and join the ranks of Those In The Know.

As for this app, it was first developed at the IMA Lab by former Lab employee [Daniel Cervantes](https://www.linkedin.com/profile/view?id=67166968), for use as a kiosk-type app for in-gallery use during exhibitions. It consumes TAP data in the TourML format, either in a local exported bundle, or by loading it over the network, and then presents the data in a few different pre-defined view types.

TODO explain that a TAP CMS installation is required to generate the content, I guess?

Now let's talk about those view types.

## Timeline "Stop" View
The timeline view is, more or less, what it sounds like. It maps a series of event stops contained by a stop group to events mapped out on a horizontally scrolling timeline. The structure of the underlying data this view expects looks like this:
### Backing data structure for this view
- Stop Group (the timeline container)
	- Event Stops (the events plotted on the timeline)
### Config setup in TAPConfig.plist
#### You must set these keys/values in the NavigationItems section of TAPConfig.plist
- view: The name of the view controller class to use for instantiating the view.
- title: The onscreen title of the stop in the header navigation.
- keycode: The stop code of the stop that backs this view. This is how you link the particular piece of content to the presented view.
- trackedViewName: The title used for analytics purposes.

## Grid View
This view presents a grid of an arbitrary number of section thumbnails which then allow the user to drill into a group of stops containing content around that theme.
### Backing data structure for this view
- Stop Group (the grid)
	- Stop Group(s) (the grid detail)
		- Image/Video/Audio Stop(s)
### Config setup in TAPConfig.plist
#### You must set these keys/values in the NavigationItems section of TAPConfig.plist
- view: The name of the view controller class to use for instantiating the view.
- title: The onscreen title of the stop in the header navigation.
- keycode: The stop code of the stop that backs this view. This is how you link the particular piece of content to the presented view.
- trackedViewName: The title used for analytics purposes.
- itemsPerRow: number of section thumbnails to display per row of the grid
- columnWidth: 
- rowHeight: 
- verticalSpacing: Spacing between rows of the grid.


## Grid Detail View
This is just the singular view that the Grid View drills into, but which can also be used as a top-level view.
### Backing data structure for this view
- Stop Group (the grid detail)
	- Image/Video/Audio Stops

## Video Group View
This view is used to represent a bunch of categorized video stops in a horizontally scrolling page view.
better explanation of what the categories are
### Backing data structure for this view
- Stop Group
	- NEW STOP TYPE TO NOT HAVE TO CUSTOMIZE VIDEO STOP

## Generic Web Container View
This is a container for loading LOCAL web content into a UIWebView. It has no backing TourML content, just what you put in the WebContainerContent.html file.


## Getting Started
TAP iPad comes with a super-generic content bundle containing examples of the available views, and a config file (TAPConfig.plist) that points to it.


# TODO
- add documentation for custom stops - use the features module to add the stops to your tap install