//
//  MultiCell.h
//  TAP iPAD
//
//  Created by David D'Amico on 9/10/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TAPAsset.h"
#import "TAPStop.h"

@interface MultiCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *image;
@property (nonatomic, weak) IBOutlet UIView *imageZoomView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIWebView *caption;
@property (nonatomic, strong) NSURL *videoUrl;
- (void)removeVideo;
- (void)setupVideoStopWithVideoUrl:(NSURL *)videoUrl stop:(TAPStop *)stop placeholderImage:(UIImage *)placeholderImage playButtonImage:(UIImage *)playButtonImage;
- (void)setupImageStopWithImage:(UIImage *)image stop:(TAPStop *)stop;
- (void)setupImageStopWithZoomImage:(TAPAsset *)image stop:(TAPStop *)stop;
@end
