//
//  TAPTimelineViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "ArrowView.h"
#import "TAPTimelineViewController.h"
#import "TAPTimelineDetailViewController.h"
#import "TimelineView.h"
#import "TimelineEventCell.h"
#import "NSDictionary+TAPUtils.h"


// vendor
#import "VSTheme.h"
#import "TAPTour.h"
#import "TAPConnection.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPHelper.h"

// @TODO pull these out into config, set defaults if not present
// @TODO also expand documentation to explain how these work - use the actual usage example to explain it
#define DEAULT_YEAR_SPACING_BEFORE 40.0f
#define DEAULT_YEAR_SPACING_AFTER 40.0f
#define DEAULT_YEAR_SPLIT 1945

#define DEAULT_CELL_WIDTH 275.0f// @TODO do we still use this?
#define DEAULT_IMAGE_TAG 1000

@interface TAPTimelineViewController () {
    int _startYear;
    int _endYear;
    float _beforeSplitWidth;
    float _afterSplitWidth;
}
@property (nonatomic, weak) IBOutlet TimelineView *timelineView;
@property (nonatomic, weak) IBOutlet UILabel *helpText;
@property (nonatomic, strong) TAPStop *stop;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) ArrowView *arrowIndicator;
@property (nonatomic, strong) NSString *trackedViewName;
@property (nonatomic, strong) VSTheme *theme;

@property float year_spacing_before;
@property float year_spacing_after;
@property float year_split;
@property float cell_width;
@property float image_tag;

@end

@implementation TAPTimelineViewController

- (id)initWithConfigDictionary:(NSDictionary *)config
{
    NSArray *requiredKeys = @[@"title", @"keycode", @"trackedViewName", @"yearSplit", @"imageTag", @"cellWidth", @"yearSpacingBefore", @"yearSpacingAfter"];
    if ([config containsAllKeysIn:requiredKeys]) {
        
        // config validation
        // @TODO offload to a utility method
        if ((NSNumber *)[config objectForKey:@"yearSpacingBefore"] != nil) {
            self.year_spacing_before = [(NSNumber *)[config objectForKey:@"yearSpacingBefore"] floatValue];
        } else {
            self.year_spacing_before = DEAULT_YEAR_SPACING_BEFORE;
        }
        if ((NSNumber *)[config objectForKey:@"yearSpacingAfter"] != nil) {
            self.year_spacing_after = [(NSNumber *)[config objectForKey:@"yearSpacingAfter"] floatValue];
        } else {
            self.year_spacing_after = DEAULT_YEAR_SPACING_AFTER;
        }
        if ((NSNumber *)[config objectForKey:@"yearSplit"] != nil) {
            self.year_split = [(NSNumber *)[config objectForKey:@"yearSplit"] floatValue];
        } else {
            self.year_split = DEAULT_YEAR_SPLIT;
        }
        if ((NSNumber *)[config objectForKey:@"cellWidth"] != nil) {
            self.cell_width = [(NSNumber *)[config objectForKey:@"cellWidth"] floatValue];
        } else {
            self.cell_width = DEAULT_CELL_WIDTH;
        }
        if ((NSNumber *)[config objectForKey:@"imageTag"] != nil) {
            self.image_tag = [(NSNumber *)[config objectForKey:@"imageTag"] floatValue];
        } else {
            self.image_tag = DEAULT_IMAGE_TAG;
        }
        
        self = [self initWithStopTitle:[config objectForKey:@"title"]
                               keycode:[config objectForKey:@"keycode"]
                       trackedViewName:[config objectForKey:@"trackedViewName"]];
    } else {
        self = nil;
    }
    return self;
}

- (id)initWithStopTitle:(NSString *)stopTitle keycode:(NSString *)keycode trackedViewName:(NSString *)trackedViewName
{
    // new init like others to init from TAPConfig, I guess?
    
    self = [super init];
    if (self) {
        [self setTitle:stopTitle];
        self.screenName = trackedViewName;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.stop = [appDelegate.currentTour stopFromKeycode:keycode];
        
        self.theme = appDelegate.theme;
        
        NSMutableArray *eventStops = [[NSMutableArray alloc] init];
        for (TAPConnection *connection in [self.stop.sourceConnection allObjects]) {
            [eventStops addObject:connection.destinationStop];
        }
        self.events = [eventStops sortedArrayUsingSelector:@selector(compareByDate:)];
        
        // obtain first and last stop
        TAPStop *firstEvent = [self.events objectAtIndex:0];
        TAPStop *lastEvent = [self.events lastObject];
        // get earliest/latest event dates
        NSDate *startDate = [TAPHelper convertStringToDate:[firstEvent getPropertyValueByName:@"date_start_0"]];
        NSDate *endDate = [TAPHelper convertStringToDate:[lastEvent getPropertyValueByName:@"date_end_0"]];
        // get year components
        NSDateComponents *startDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:startDate];
        NSDateComponents *endDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:endDate];
        // keep track of years
        _startYear = startDateComponents.year - 2.0f;
        _endYear = endDateComponents.year + 1.0f;
        // set scrollview widths
        _beforeSplitWidth = (self.year_split - _startYear) * self.year_spacing_before;
        _afterSplitWidth = (_endYear - self.year_split) * self.year_spacing_after;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // hide navigation controller
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.timelineView registerClass:[TimelineEventCell class] forCellReuseIdentifier:@"TimelineEventCell"];
    
    // set help text font
    // @TODO this started out as franklin gothic @ 17pt, probably not the right font to use here but save that for later
    [self.helpText setFont:[self.theme fontForKey:@"bodyFont"]];
    
    // add arrow indicator animation
    self.arrowIndicator = [[ArrowView alloc] initWithFrame:CGRectMake(929.0f, 650.0f, 75.0f, 35.0f)];
    [self.view addSubview:self.arrowIndicator];
}

-(void)viewWillAppear:(BOOL)animated
{
    // return to scroll position
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.timelineView setContentOffset:CGPointMake(appDelegate.timelineScrollPosition, 0)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) viewWillDisappear:(BOOL)animated
{
    // retain scroll position
    [super viewWillDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setTimelineScrollPosition:self.timelineView.contentOffset.x];
}

# pragma mark - TimelineView Datasource

- (CGSize)contentSizeForTimelineView:(TimelineView *)timelineView
{  
    return CGSizeMake(_beforeSplitWidth + _afterSplitWidth, self.timelineView.bounds.size.height);
}

- (void)didFinishLayingSubviewsForTimelineView:(TimelineView *)timeline
{
    float currentSpacing = self.year_spacing_before;
    int tickPosition = self.year_spacing_before;
    int currentYear = _startYear + 1;

    while (tickPosition < timeline.contentSize.width) {
        UIView *tickVew = [[UIView alloc] initWithFrame:CGRectMake(tickPosition - (currentSpacing / 2), (timeline.contentSize.height / 2) - 50.0f, currentSpacing, 100.0f)];
        
        UIView *tickLine = [[UIView alloc] initWithFrame:CGRectMake((tickVew.frame.size.width / 2) - 0.75f, (tickVew.frame.size.height / 2) - 8.0f, 1.5f, 16.0f)];
        [tickLine setBackgroundColor:[UIColor lightGrayColor]];
        [tickVew addSubview:tickLine];
        
        UILabel *yearTick = [[UILabel alloc] initWithFrame:CGRectMake(0, 58.0f, (currentSpacing > 30.0) ? currentSpacing : 30.0, 20.0f)];
        [yearTick setText:[NSString stringWithFormat:@"%d", currentYear]];
        [yearTick setBackgroundColor:[UIColor clearColor]];
        [yearTick setFont:[self.theme fontForKey:@"bodyFont"]];
        [yearTick setTextColor:[self.theme colorForKey:@"bodyFontColor"]];
        [yearTick setTextAlignment:NSTextAlignmentCenter];
        [tickVew addSubview:yearTick];
        
        [timeline addSubview:tickVew];
        [timeline sendSubviewToBack:tickVew];

        tickPosition += currentSpacing * 5;
        currentYear += 5;

        if (tickPosition >= _beforeSplitWidth) {
            currentSpacing = self.year_spacing_after;
        }
    }
}

- (NSInteger)numberOfCellsInTimelineView:(TimelineView *)timelineView
{
    return [self.events count];
}

- (CGRect)timelineView:(TimelineView *)timelineView cellFrameForIndex:(NSInteger)index
{
    TAPStop *event = [self.events objectAtIndex:index];
    // get earliest/latest event dates
    NSDate *startDate = [TAPHelper convertStringToDate:[event getPropertyValueByName:@"date_start_0"]];
    NSDate *endDate = [TAPHelper convertStringToDate:[event getPropertyValueByName:@"date_end_0"]];
    
    // get year components
    NSDateComponents *startDateComponent = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:startDate];
    NSDateComponents *endDateComponent = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:endDate];
    
    float x = 0;
    float width = 0;
    
    // calculate x and width based on start/end dates
    if (startDateComponent.year == endDateComponent.year) {
        width = self.cell_width;
        if (startDateComponent.year <= self.year_split) {
            x = (startDateComponent.year - _startYear) * self.year_spacing_before - (self.cell_width / 2);
        } else {
            x = ((startDateComponent.year - self.year_split) * self.year_spacing_after + _beforeSplitWidth) - (self.cell_width / 2);
        }
        
    } else {
        float startDateWidth = 0;
        if (startDateComponent.year <= self.year_split) {
            startDateWidth = (startDateComponent.year - _startYear) * self.year_spacing_before;
        } else {
            startDateWidth = ((startDateComponent.year - self.year_split) * self.year_spacing_after) + _beforeSplitWidth;
        }
        
        float endDateWidth = 0;
        if (endDateComponent.year <= self.year_split) {
            endDateWidth = (endDateComponent.year - _startYear) * self.year_spacing_before;
        } else {
            endDateWidth = ((endDateComponent.year - self.year_split) * self.year_spacing_after) + _beforeSplitWidth;
        }
        
        width = endDateWidth - startDateWidth;
        
        x = startDateWidth;
    }

    return CGRectMake(x, 0, width, timelineView.contentSize.height);
}

- (TimelineViewCell *)timelineView:(TimelineView *)timelineView cellForIndex:(NSInteger)index
{
    TAPStop *eventStop = [self.events objectAtIndex:index];
    TimelineEventCell *cell = (TimelineEventCell *)[timelineView dequeueReuseableViewWithIdentifier:@"TimelineEventCell" forIndex:index];
    
    // determine where to position the content
    if (index % 2 == 0) {
        [cell setFlipCell:NO];
    } else {
        [cell setFlipCell:YES];
    }

    // set title/date image
    TAPAsset *eventTitleAsset = [[eventStop getAssetsByUsage:@"image"] objectAtIndex:0];
    NSString *eventTitleImage = [[[eventTitleAsset source] anyObject] uri];
    if (eventTitleImage != nil) {
        [cell.eventTitle setImage:[UIImage imageWithContentsOfFile:eventTitleImage]];
    }
    
    // set theme image
    TAPAsset *eventAsset = [[eventStop getAssetsByUsageOrderByParseIndex:@"image_asset"] objectAtIndex:0];
    NSString *eventImage = [[[eventAsset getSourcesByPart:@"400_maxheight"] objectAtIndex:0] uri];
    [cell.eventImage setImage:[UIImage imageWithContentsOfFile:eventImage]];
    
    // set cell start/end dates
    [cell setStartDate:[TAPHelper convertStringToDate:[eventStop getPropertyValueByName:@"date_start_0"]]];
    [cell setEndDate:[TAPHelper convertStringToDate:[eventStop getPropertyValueByName:@"date_end_0"]]];
    
    // layout the cell
    [cell setupLayout];
    
    // set image gesture recognizer
    UITapGestureRecognizer *singleTapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventSelected:)];
    [singleTapImage setNumberOfTapsRequired:1];
    [singleTapImage setNumberOfTouchesRequired:1];
    [cell.eventImage addGestureRecognizer:singleTapImage];
    [cell.eventImage setUserInteractionEnabled:YES];
    [cell.eventImage setTag:self.image_tag + index];

    // set title gesture recognizer
    UITapGestureRecognizer *singleTapTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventSelected:)];
    [singleTapTitle setNumberOfTapsRequired:1];
    [singleTapTitle setNumberOfTouchesRequired:1];
    [cell.eventTitle addGestureRecognizer:singleTapTitle];
    [cell.eventTitle setUserInteractionEnabled:YES];
    [cell.eventTitle setTag:self.image_tag + index];
    
    return cell;
}

# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    if (scrollView.contentOffset.x == 0) {
        [self.arrowIndicator setHidden:NO];
    } else {
        [self.arrowIndicator setHidden:YES];
    }
}

# pragma mark - Gestures

- (void)eventSelected:(UIGestureRecognizer *)gestureRecognizer {
    int index = [[gestureRecognizer view] tag] - self.image_tag;
    
    // initialize themes stop controller
    TAPTimelineDetailViewController *eventStopDetailViewController = [[TAPTimelineDetailViewController alloc] initWithEventStop:[self.events objectAtIndex:index]];
    
    // create fade transition
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    // push view theme view controller onto the stack
    [self.navigationController pushViewController:eventStopDetailViewController animated:NO];
    
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
}

@end
