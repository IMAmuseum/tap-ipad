//
//  EventStopCell.h
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/22/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPStop.h"

@interface EventStopCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *imageTitle;
@property (nonatomic, weak) IBOutlet UIWebView *imageCaption;
@property (nonatomic, weak) IBOutlet UIWebView *content;
@property (nonatomic, weak) IBOutlet UIImageView *image;
@end
