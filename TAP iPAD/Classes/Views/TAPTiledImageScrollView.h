//
//  TLPTiledImageScrollView.h
//  image test
//
//  Created by Kyle Jaebker on 3/4/14.
//  Copyright (c) 2014 Kyle Jaebker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPTiledImageScrollView : UIScrollView

@property (nonatomic) NSString* imagePath;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *twoFingerTapGestureRecognizer;

- (void)maxZoomToPoint:(CGPoint)point;

@end
