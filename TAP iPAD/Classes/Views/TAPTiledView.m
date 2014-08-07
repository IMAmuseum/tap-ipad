//
//  TAPTiledView.m
//  image test
//
//  Created by Kyle Jaebker on 3/4/14.
//  Copyright (c) 2014 Kyle Jaebker. All rights reserved.
//

#import "TAPTiledView.h"

@implementation TAPTiledView
{
    NSString *_imagePath;
    NSArray *_manifest;
}

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (id)initWithImagePath:(NSString *)path manifest:(NSArray *)manifest size:(CGSize)size
{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _imagePath = path;
        _manifest = manifest;

        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        tiledLayer.opaque = NO;
        tiledLayer.levelsOfDetail = [_manifest count];
        tiledLayer.levelsOfDetailBias = 1;
        tiledLayer.tileSize = (CGSize){512,512};
    }
    return self;
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:1.f];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat scaleX = CGContextGetCTM(context).a;
    CGFloat scaleY = CGContextGetCTM(context).d;
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    CGSize tileSize = tiledLayer.tileSize;
    
    tileSize.width /= scaleX;
    tileSize.height /= -scaleY;

    // calculate the rows and columns of tiles that intersect the rect we have been asked to draw
    int firstCol = floorf(CGRectGetMinX(rect) / tileSize.width);
    int lastCol = floorf((CGRectGetMaxX(rect)-1) / tileSize.width);
    int firstRow = floorf(CGRectGetMinY(rect) / tileSize.height);
    int lastRow = floorf((CGRectGetMaxY(rect)-1) / tileSize.height);
    
    int useScale = [self getZoomForScaleX:scaleX scaleY:scaleY];

    if (useScale == 0) {
        return;
    }
    
    for (int row = firstRow; row <= lastRow; row++) {
        for (int col = firstCol; col <= lastCol; col++) {
            UIImage *tile = [self tileForScale:useScale row:row col:col];
            
            CGRect tileRect = CGRectMake(tileSize.width * col, tileSize.height * row,
                                         tileSize.width, tileSize.height);

            // if the tile would stick outside of our bounds, we need to truncate it so as
            // to avoid stretching out the partial tiles at the right and bottom edges
            //tileRect = CGRectIntersection(self.bounds, tileRect);

            [tile drawInRect:tileRect blendMode:kCGBlendModeNormal alpha:1];

//            [[UIColor blackColor] set];
//            CGContextSetLineWidth(context, 6.0);
//            CGContextStrokeRect(context, tileRect);
        }
    }
}

- (UIImage *)tileForScale:(int)scale row:(int)row col:(int)col
{
    NSString *tileUrl = [NSString stringWithFormat:@"%@zoom%d/row%d/col%d.png", _imagePath, (int)scale, (int)row, (int)col];
//    NSLog(tileUrl);
    
    UIImage *image;
    if ([tileUrl rangeOfString:@"http://"].location == NSNotFound) {
        image = [UIImage imageWithContentsOfFile:tileUrl];
    } else {
        NSURL *url = [NSURL URLWithString:tileUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
    }

    return image;
}

- (int)getZoomForScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY
{
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    CGSize tileSize = tiledLayer.tileSize;
    
    id maxZoomLayer = [_manifest lastObject];
    int maxWidth = [[maxZoomLayer objectForKey:@"width"] intValue];
    int maxHeight = [[maxZoomLayer objectForKey:@"height"] intValue];
    
    CGFloat currentTilesWide = maxWidth * scaleX / tileSize.width;
    CGFloat currentTilesHigh = maxHeight * -scaleY / tileSize.height;
    
    int zoom = 0;
    for (id layer in _manifest) {
        int tilesHigh = [[layer objectForKey:@"tiles_high"] intValue];
        int tilesWide = [[layer objectForKey:@"tiles_wide"] intValue];

        if (tilesHigh > currentTilesHigh || tilesWide > currentTilesWide || zoom == [_manifest count] - 1) {
            break;
        }
        
        zoom++;
    }

    return zoom;
}

@end
