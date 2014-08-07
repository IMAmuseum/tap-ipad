//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/TimelineView
//  Distributed under MIT license
//

#import <Foundation/Foundation.h>

@class TimelineView;
@class TimelineViewCell;

@protocol TimelineViewDataSource <NSObject>
@required

- (CGSize)contentSizeForTimelineView:(TimelineView *)timelineView;
- (NSInteger)numberOfCellsInTimelineView:(TimelineView *)timelineView;
- (CGRect)timelineView:(TimelineView *)timelineView cellFrameForIndex:(NSInteger)index;
- (TimelineViewCell *)timelineView:(TimelineView *)timelineView cellForIndex:(NSInteger)index;

@optional
- (void)didFinishLayingSubviewsForTimelineView:(TimelineView *)timeline;
- (BOOL)timelineView:(TimelineView *)timelineView canMoveCellAtIndex:(NSInteger)index;
- (void)timelineView:(TimelineView *)timelineView moveCellAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex withFrame:(CGRect)frame;

@end
