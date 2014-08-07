//
//  NewThemeCell.m
//  TAP iPAD
//
//  Created by David D'Amico on 9/10/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "NewThemeCell.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <AVFoundation/AVFoundation.h>
#import "TAPSource.h"
#import "TAPTiledImageScrollView.h"
#import "TAPStop.h"

@interface NewThemeCell()
@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) NSString *stopTitle;
@end

@implementation NewThemeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeVideo];
    }
    return self;
}

#pragma mark - convenience setup methods
-(void)setupVideoStopWithVideoUrl:(NSURL *)videoUrl
                             stop:(TAPStop *)stop
                 placeholderImage:(UIImage *)placeholderImage
                  playButtonImage:(UIImage *)playButtonImage
{
    
    [self.caption removeFromSuperview];
    [self setStopTitle:(NSString *)stop.title];
    [self.image setContentMode:UIViewContentModeScaleAspectFit];
    [self.image setImage:placeholderImage];
    
    // intervene to move the video into a nicer vertical position,
    // garbage way to do this, rip it out and start over with autolayout once
    // you understand it better
    self.image.center = CGPointMake(self.image.center.x, self.image.center.y + (self.caption.bounds.size.height / 2));
    self.videoView.bounds = self.image.bounds;
    self.videoView.center = self.image.center;
    self.playButton.center = self.image.center;
    [self.caption removeFromSuperview];
    
    [self.playButton setImage:playButtonImage forState:UIControlStateNormal];
    [self setVideoUrl:videoUrl];
    [self.imageZoomView setHidden:YES];
}

-(void)setupImageStopWithImage:(UIImage *)image
                          stop:(TAPStop *)stop
{
    [self setStopTitle:(NSString *)stop.title];
    [self.image setContentMode:UIViewContentModeScaleAspectFit];
    [self.image setImage:image];
    [self.videoView setHidden:YES];
    [self.playButton setHidden:YES];
    [self.imageZoomView setHidden:YES];
}

- (void)setupImageStopWithZoomImage:(TAPAsset *)image stop:(TAPStop *)stop {
    [self setStopTitle:(NSString *)stop.title];

    NSString *tileUri = [[[image getSourcesByPart:@"tiles"] objectAtIndex:0] uri];
    
    CGRect scrollViewFrame = CGRectMake(0,
                                        0,
                                        self.imageZoomView.frame.size.width,
                                        self.imageZoomView.frame.size.height);
    TAPTiledImageScrollView *scrollView = [[TAPTiledImageScrollView alloc] initWithFrame:scrollViewFrame];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [scrollView setImagePath:tileUri];
    NSString *poi = [stop getPropertyValueByName:@"point_of_interest"];
    if (poi != nil) {
        CGPoint myPoint = CGPointFromString([NSString stringWithFormat:@"{%@}",poi]);
        [scrollView maxZoomToPoint:myPoint];
    }
    [self.imageZoomView addSubview:scrollView];
    
    [self.image setHidden:YES];
    [self.videoView setHidden:YES];
    [self.playButton setHidden:YES];
}

#pragma mark - video playback methods, repurposed from interviewquestioncell. thanks Dan!
- (void)initializeVideo
{
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.videoUrl];

    // get video dimensions to make determination about scaling mode
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.videoUrl options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CGSize mediaSize = track.naturalSize;
    
    [self.moviePlayer.view setFrame: self.videoView.bounds];
    if (mediaSize.width > 720) {
        [self.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    } else {
        [self.moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    }
//    [self.moviePlayer.view setBackgroundColor:[UIColor whiteColor]];
//    [self.videoView setBackgroundColor:[UIColor whiteColor]];
    [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
    [self.moviePlayer prepareToPlay];
    [self.videoView addSubview:self.moviePlayer.view];
    
    // Add finished observer
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlayBackDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:self.moviePlayer];
}

- (void)removeVideo
{
    [self.moviePlayer stop];
    [self.moviePlayer setContentURL:nil];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self.playButton setHidden:NO];
    [self.image setHidden:NO];
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"Navigated Away" label:self.stopTitle value:nil] build]];
}

- (IBAction)toggleVideoState:(id)sender
{
    //NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.question.text, @"Question", nil];
    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.moviePlayer pause];
        // register event
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_pause" label:self.stopTitle value:nil] build]];
    } else {
        if (self.moviePlayer == nil) {
            [self initializeVideo];
        }
        [self.playButton setImage:nil forState:UIControlStateNormal];
        [self.image setHidden:YES];
        [self.moviePlayer play];
        // register event
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_play" label:self.stopTitle value:nil] build]];
    }
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification
{
    // reset movie player
    [self.moviePlayer setCurrentPlaybackTime:self.moviePlayer.endPlaybackTime];
    [self.image setHidden:NO];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_complete" label:self.stopTitle value:nil] build]];
    
}

@end
