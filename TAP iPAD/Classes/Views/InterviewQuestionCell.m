//
//  InterviewQuestionCell.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/12/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "InterviewQuestionCell.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface InterviewQuestionCell()
@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

- (IBAction)toggleVideoState:(id)sender;

@end

@implementation InterviewQuestionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        

    }
    return self;
}

- (void)initializeVideo
{
//    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.videoUrl];
//    [self.moviePlayer.view setFrame: self.videoView.bounds];
//    [self.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
//    [self.moviePlayer prepareToPlay];
//    [self.moviePlayer setFullscreen:YES];
//    [self.videoView addSubview:self.moviePlayer.view];
    
    
    // Add finished observer
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlayBackDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:self.parent.moviePlayer];
}

- (void)removeVideo
{
//    [self.moviePlayer stop];
//    [self.moviePlayer setContentURL:nil];
//    [self.moviePlayer.view removeFromSuperview];
//    self.moviePlayer = nil;
    
    [self.playButton setHidden:NO];
    [self.posterImage setHidden:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.parent.moviePlayer];
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"Navigated Away" label:self.question.text value:nil] build]];
}

- (IBAction)toggleVideoState:(id)sender
{
    [self initializeVideo];
    //NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.question.text, @"Question", nil];
//    if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
//        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//        [self.moviePlayer pause];
//        // register event
//        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_pause" label:self.question.text value:nil] build]];
//    } else {
//        if (self.moviePlayer == nil) {
//            [self initializeVideo];
//        }
//        
//        [self.playButton setImage:nil forState:UIControlStateNormal];
//        [self.posterImage setHidden:YES];
//        [self.moviePlayer play];
        // register event
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_play" label:self.question.text value:nil] build]];
//    }
    [self.parent playVideoWithUrl:self.videoUrl];
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification
{
    // reset movie player
//    [self.moviePlayer setCurrentPlaybackTime:self.moviePlayer.endPlaybackTime];
    [self.posterImage setHidden:NO];
//    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    // register event
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Video Stop" action:@"video_complete" label:self.question.text value:nil] build]];

}

@end