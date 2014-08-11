//
//  UnderlineButton.m
//  TAP iPAD
//
//  Created by Daniel Cervantes on 3/14/13.
//  Copyright (c) 2013 IMA Lab. All rights reserved.
//


#import "UnderlineButton.h"
#import "VSTheme.h"

@interface UnderlineButton() {
    BOOL _active;
}
@property (nonatomic, strong) VSTheme *theme;
@end

@implementation UnderlineButton

-(id)initWithTheme:(VSTheme *)theme
{
    self = [super init];
    if (self != nil) {
        self.theme = theme;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_active) {
        UIColor *activeColor = (self.theme == nil) ? [UIColor blackColor] : [self.theme colorForKey:@"accentColor"];
        CGContextSetStrokeColorWithColor(context, [activeColor CGColor]);
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
