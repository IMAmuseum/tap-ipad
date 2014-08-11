//
//  UnderlineLabel.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/18/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "UnderlineLabel.h"

@implementation UnderlineLabel

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:192.0/255.0 green:62.0/255.0 blue:25.0/255.0 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 3.0f);
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height - 1);
    CGContextAddLineToPoint(ctx, self.bounds.size.width, self.bounds.size.height - 1);
    
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];
}

@end
