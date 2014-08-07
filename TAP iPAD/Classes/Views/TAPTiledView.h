//
//  TAPTiledView.h
//  image test
//
//  Created by Kyle Jaebker on 3/4/14.
//  Copyright (c) 2014 Kyle Jaebker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPTiledView : UIView

- (id)initWithImagePath:(NSString *)path manifest:(NSArray *)manifest size:(CGSize)size;
- (UIImage *)tileForScale:(int)scale row:(int)row col:(int)col;

@end
