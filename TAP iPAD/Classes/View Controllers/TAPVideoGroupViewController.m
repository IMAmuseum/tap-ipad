//
//  TAPInterviewsViewController.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/4/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "ArrowView.h"
#import "InterviewIntroductionCell.h"
#import "InterviewQuestionCell.h"
#import "TAPVideoGroupViewController.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPConnection.h"
#import "UnderlineButton.h"
#import "NSDictionary+TAPUtils.h"

// vendor
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "VSTheme.h"

#define CELL_OFFSET 1024.0f
#define SECTION_TAG_OFFSET 1000
#define SECTION_MENU_SPACING 20

@interface TAPVideoGroupViewController () {
    NSInteger _currentIndex;
    NSInteger _currentSection;
}
@property (nonatomic, strong) TAPStop *stop;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSMutableDictionary *categoryStops;
@property (nonatomic, strong) ArrowView *arrowIndicator;
@property (nonatomic, weak) InterviewQuestionCell *currentCell;
@property (nonatomic, weak) IBOutlet UIView *header;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIPageControl *pager;
@property (nonatomic, strong) VSTheme *theme;

- (NSInteger)getSectionOffset:(NSInteger)section;
- (void)sectionNavigationClicked:(UIButton *)sender;
- (void)navigateToSection:(NSInteger)section;
- (void)updateSupplementalSections;
- (void)toggleArrowIndicator;
@end

@implementation TAPVideoGroupViewController

-(id)initWithConfigDictionary:(NSDictionary *)config
{
    self = [super initWithConfigDictionary:config];
    if (self) {
        // validate incoming config values
        NSArray *requiredKeys = @[@"title", @"keycode", @"trackedViewName"];
        if ([config containsAllKeysIn:requiredKeys]) {
            
        } else {
            NSLog(@"Tried to instantiate TAPVideoGroupViewController without all required config items, please check TAPConfig");
            self = nil;
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Interviews"];
        self.screenName = @"Interviews";
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.stop = [appDelegate.currentTour stopFromKeycode:@"300"];
        
        self.theme = appDelegate.theme;

        // setup categories
        NSMutableArray *tempSections = [[NSMutableArray alloc] init];
        self.categoryStops = [[NSMutableDictionary alloc] init];
        // organize stops according to category
        for (TAPConnection *connection in [self.stop.sourceConnection allObjects]) {
            TAPStop *interviewStop = connection.destinationStop;
            NSString *category = [interviewStop getPropertyValueByName:@"category"];
            if ([tempSections containsObject:category] == false) {
                [tempSections addObject:category];
            }
            if ([category length] != 0) {
                if ([self.categoryStops objectForKey:category]) {
                    [[self.categoryStops objectForKey:category] addObject:interviewStop];
                } else {
                    NSMutableArray *stops = [[NSMutableArray alloc] initWithObjects:interviewStop, nil];
                    [self.categoryStops setValue:stops forKey:category];
                }
            }
        }
        self.sections = tempSections;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // initialize defaults
    _currentIndex = 0;
    _currentSection = 0;
    
    // register custom cells;
    [self.collectionView registerNib:[UINib nibWithNibName:@"InterviewIntroductionCell" bundle:nil] forCellWithReuseIdentifier:@"InterviewIntroductionCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"InterviewQuestionCell" bundle:nil] forCellWithReuseIdentifier:@"InterviewQuestionCell"];
    
    // add header label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0, 140.0f, self.header.frame.size.height)];
    [headerLabel setText:@"VIDEO TOPICS:"];
    [headerLabel setFont:[self.theme fontForKey:@"headingFont"]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:headerLabel];

    // add header section buttons
    NSUInteger index = 0;
    float previousWidth = 0;
    
    for (NSString *section in self.sections) {
        NSMutableAttributedString *attributedSection = [[NSMutableAttributedString alloc] initWithString:section];
        [attributedSection addAttribute:NSFontAttributeName value:[self.theme fontForKey:@"headingFont"] range:NSMakeRange(0, [attributedSection length])];
        [attributedSection addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [attributedSection length])];

        if (index != 0) {
            NSInteger count = [[self.categoryStops objectForKey:[self.sections objectAtIndex:index]] count];
            NSMutableAttributedString *attributedSectionCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", [NSString stringWithFormat:@"%i", count]]];
            [attributedSectionCount addAttribute:NSFontAttributeName value:[self.theme fontForKey:@"headingFont"] range:NSMakeRange(0, [attributedSectionCount length])];
            [attributedSection appendAttributedString:attributedSectionCount];
        }
    
		UnderlineButton *button = [[UnderlineButton alloc] initWithTheme:self.theme];
        [button setTag:SECTION_TAG_OFFSET + index];
        [button setAttributedTitle:attributedSection forState:UIControlStateNormal];
		[button setTitle:section forState:UIControlStateNormal];
		[button addTarget:self action:@selector(sectionNavigationClicked:) forControlEvents:UIControlEventTouchDown];
        [button.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        
        CGSize fontSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
        CGRect buttonFrame = CGRectMake(previousWidth, 0, fontSize.width + SECTION_MENU_SPACING, self.header.frame.size.height);
        [button setFrame:buttonFrame];
        
		[self.header addSubview:button];
        
        if (index == 0) {
            [button setSelected:YES];
        }
        
        previousWidth += fontSize.width + SECTION_MENU_SPACING;
        index++;
    }
    
    // add arrow indicator animation
    self.arrowIndicator = [[ArrowView alloc] initWithFrame:CGRectMake(929.0f, 641.0f, 75.0f, 35.0f)];
    [self.view addSubview:self.arrowIndicator];
    
    [self updateSupplementalSections];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // remove last video
    [self.currentCell removeVideo];
    
    // navigate back to the front
    [self navigateToSection:0];
        
    // update supplemental sections
    [self updateSupplementalSections];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)getSectionOffset:(NSInteger)section
{
    int offset = 0;
    
    if (section == 0) {
        offset = 0;
    } else if (section == 1) {
        offset = 1;
    } else {
        for (NSInteger index = 0; index < section; index++) {
            offset +=  [[self.categoryStops objectForKey:[self.sections objectAtIndex:index]] count];
        }
        offset++;
    }
    return offset;
}

- (void)updateSupplementalSections
{
    int sectionTag = _currentSection + SECTION_TAG_OFFSET;
    for (UIButton *button in [self.header subviews]) {
        if ([button tag] == sectionTag) {
            [button setSelected:YES];
        } else {
            [button setSelected:NO];
        }
    }
    
    // set number of pages
    NSString *sectionName = [self.sections objectAtIndex:_currentSection];
    NSInteger pages =[[self.categoryStops objectForKey:sectionName] count];
    if (pages == 0) {
        [self.pager setHidden:YES];
    } else {
        [self.pager setHidden:NO];
        [self.pager setNumberOfPages:pages];
    }
}

- (void)sectionNavigationClicked:(UIButton *)sender
{
    int index = sender.tag - SECTION_TAG_OFFSET;
    [self navigateToSection:index];
    [self updateSupplementalSections];
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Interviews" action:@"Selected Section" label:[self.sections objectAtIndex:index] value:[NSNumber numberWithBool:TRUE]] build]];
}

- (void)navigateToSection:(NSInteger)section
{
    if (section == _currentSection) return;
    
    _currentIndex = [self getSectionOffset:section];
    float offsetWidth = _currentIndex * CELL_OFFSET;

    _currentSection = section;
    
    [self toggleArrowIndicator];
    [self.pager setCurrentPage:0];
    [self.collectionView setContentOffset:CGPointMake(offsetWidth, 0) animated:NO];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        NSString *sectionName = [self.sections objectAtIndex:section];
        return [[self.categoryStops objectForKey:sectionName] count];
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.sections count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentSection = indexPath.section;
    
    // remove previous cells video
    if (self.currentCell != nil) {
        [self.currentCell removeVideo];
    }
    
    if (indexPath.section == 0) {
        InterviewIntroductionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"InterviewIntroductionCell" forIndexPath:indexPath];
        [cell.title setFont:[self.theme fontForKey:@"headingFont"]];
        [cell.content setFont:[self.theme fontForKey:@"headingFont"]];
        return cell;
    } else {
        InterviewQuestionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"InterviewQuestionCell" forIndexPath:indexPath];
        NSString *sectionName = [self.sections objectAtIndex:indexPath.section];
        TAPStop *stop = [[self.categoryStops objectForKey:sectionName] objectAtIndex:indexPath.row];
        
        // set question
        [cell.question setText:(NSString *)stop.title];
        [cell.question setFont:[self.theme fontForKey:@"headingFont"]];
        
        // set video url
        TAPAsset *videoAsset = [[stop getAssetsByUsage:@"video"] objectAtIndex:0];
        NSString *videoPath = [[[videoAsset source] anyObject] uri];
        [cell setVideoUrl:[NSURL fileURLWithPath:videoPath]];
        
        // set poster image
        TAPAsset *posterAsset = [[stop getAssetsByUsage:@"image"] objectAtIndex:0];
        NSString *posterImage = [[[posterAsset source] anyObject] uri];
        [cell.posterImage setImage:[UIImage imageWithContentsOfFile:posterImage]];

        // set button image
        [cell.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        
        // register event
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[[GAIDictionaryBuilder createAppView] set:(NSString *)stop.title
                                                          forKey:kGAIScreenName] build]];
        
        self.currentCell = cell;
        return cell;
    }
}

- (void)toggleArrowIndicator
{
    if (_currentIndex == 0) {
        [self.arrowIndicator setHidden:NO];
    } else {
        [self.arrowIndicator setHidden:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // reset timer
    [(KioskApplication *)[[UIApplication sharedApplication] delegate] resetIdleTimer];
    
    if (self.currentCell != nil) {
        [self.currentCell removeVideo];
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int index = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (_currentIndex != index) {
        _currentIndex = index;
        
        [self toggleArrowIndicator];
        [self updateSupplementalSections];
        
        int page = _currentIndex - [self getSectionOffset:_currentSection];
        [self.pager setCurrentPage:page];
    }
}

@end
