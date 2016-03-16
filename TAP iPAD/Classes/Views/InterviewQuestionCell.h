//
//  InterviewQuestionCell.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/12/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TAPVideoGroupViewController.h"

@interface InterviewQuestionCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *question;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIImageView *posterImage;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) TAPVideoGroupViewController *parent;
- (void)removeVideo;
@end
