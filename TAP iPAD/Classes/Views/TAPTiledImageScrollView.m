//
//  TAPTiledImageScrollView.m
//  image test
//
//  Created by Kyle Jaebker on 3/4/14.
//  Copyright (c) 2014 Kyle Jaebker. All rights reserved.
//

#import "TAPTiledImageScrollView.h"
#import "TAPTiledView.h"

// forward declaration of our utility functions
static CGSize _ImageSizeForManifest(NSArray *manifest);

#pragma mark -

@interface TAPTiledImageScrollView () <UIScrollViewDelegate>
{
    CGSize _imageSize;

    NSString *_imagePath;
    TAPTiledView *_tilingView;
    NSArray *_manifest;
    
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}

@end

@implementation TAPTiledImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapReceived:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:_doubleTapGestureRecognizer];
        
        _twoFingerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTapReceived:)];
        _twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2;
        _twoFingerTapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_twoFingerTapGestureRecognizer];
    }
    
    return self;
}
    

- (void)setImagePath:(NSString *)path
{
    if([path hasSuffix:@"/"]) {
        _imagePath = path;
    } else {
        _imagePath = [NSString stringWithFormat:@"%@/", path];
    }
    
    [self fetchManifest];
    [self displayTiledImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _tilingView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _tilingView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _tilingView;
}

- (CGFloat)zoomLevel
{
    return self.zoomScale / self.maximumZoomScale;
}


#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)displayTiledImage
{
    CGSize imageSize = _ImageSizeForManifest(_manifest);
    
    // clear views for the previous image
    _tilingView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make views to display the new image
    _tilingView = [[TAPTiledView alloc] initWithImagePath:_imagePath manifest:_manifest size:imageSize];
    _tilingView.frame = (CGRect){ CGPointZero, imageSize };
    [self addSubview:_tilingView];
    
    [self configureForImageSize:imageSize];
}

- (void)maxZoomToPoint:(CGPoint)point {
    float newZoom = self.maximumZoomScale;

    //for testing
//    point.x = 2275.;
//    point.y = 1650.;

    CGRect bounds = self.bounds;
    CGSize newSize = CGSizeApplyAffineTransform(bounds.size, CGAffineTransformMakeScale(1 / newZoom, 1 / newZoom));
    [self zoomToRect:(CGRect){{point.x - (newSize.width / 2), point.y - (newSize.height / 2)}, newSize} animated:YES];
}


- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
//    CGFloat maxScale = .9 / [[UIScreen mainScreen] scale];
    CGFloat maxScale = 1.25f;
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }

    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_tilingView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_tilingView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (void)fetchManifest
{
    NSString *manifestUrl = [NSString stringWithFormat:@"%@manifest.json", _imagePath];
    NSURL *url = [[NSURL alloc] initWithString:manifestUrl];
    NSURLResponse *response = nil;
    NSError *responseError = nil;
    
    NSData *data;
    if ([manifestUrl rangeOfString:@"http://"].location == NSNotFound) {
        data = [[NSMutableData alloc] initWithContentsOfFile:manifestUrl];
    } else {
        data = [NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url]
                                     returningResponse:&response
                                                 error:&responseError];
    }
    
    _manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:&responseError];
}

#pragma mark - Gesture Support

- (void)doubleTapReceived:(UITapGestureRecognizer *)gestureRecognizer
{
    float newZoom = MIN(powf(2, (log2f(self.zoomScale) + 1.0f)), self.maximumZoomScale); //zoom in one level of detail
    
    CGRect bounds = self.bounds;
    CGPoint pointInView = CGPointApplyAffineTransform([gestureRecognizer locationInView:self], CGAffineTransformMakeScale(1/self.zoomScale, 1/self.zoomScale));
    CGSize newSize = CGSizeApplyAffineTransform(bounds.size, CGAffineTransformMakeScale(1 / newZoom, 1 / newZoom));
    [self zoomToRect:(CGRect){{pointInView.x - (newSize.width / 2), pointInView.y - (newSize.height / 2)}, newSize} animated:YES];
}

- (void)twoFingerTapReceived:(UITapGestureRecognizer *)gestureRecognizer
{
    float newZoom = MAX(powf(2, (log2f(self.zoomScale) - 1.0f)), self.minimumZoomScale); //zoom out one level of detail
    
    [self setZoomScale:newZoom animated:YES];
}

@end

static CGSize _ImageSizeForManifest(NSArray *manifest)
{
    NSDictionary *info = [manifest lastObject];
    return CGSizeMake([[info valueForKey:@"width"] floatValue],
                      [[info valueForKey:@"height"] floatValue]);
}
