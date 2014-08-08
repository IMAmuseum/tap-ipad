//
//  UnderlineButton.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/14/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//

#import "UnderlineButton.h"

@interface UnderlineButton() {
    BOOL _active;
}

@end

@implementation UnderlineButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_active) {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:172.0/255.0 green:189.0/255.0 blue:79.0/255.0 alpha:1.0] CGColor]);
    } else {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] CGColor]);
    }
    
    // Draw them with a 2.0 stroke width.
    CGContextSetLineWidth(context, 2.5);
    
    // Work out line width
    NSString *text = self.titleLabel.text;

    CGRect rt = [text boundingRectWithSize:rect.size
                                   options:NSStringDrawingTruncatesLastVisibleLine
                                attributes:@{NSFontAttributeName:self.titleLabel.font}
                                   context:nil];
    CGSize sz = rt.size;
    CGFloat width = rect.size.width;
    CGFloat offset = (rect.size.width - sz.width) / 2;
    if (offset > 0 && offset < rect.size.width) {
        width -= offset;
    } else {
        offset = 0.0;
    }
    
    // Work out line spacing to put it just below text
    CGFloat baseline = (rect.size.height / 2) + (self.titleLabel.frame.size.height / 2) + 5;
    
    // Draw a single line from left to right
    CGContextMoveToPoint(context, offset, baseline);
    CGContextAddLineToPoint(context, width, baseline);
    CGContextStrokePath(context);
}

- (void)setSelected:(BOOL)selected
{
    _active = selected;
    [self setNeedsDisplay];
}

@end
