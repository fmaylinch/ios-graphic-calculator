//
//  GraphicView.m
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize positionFromCenter = _positionFromCenter;
@synthesize scale = _scale;

- (void) setScale:(CGPoint) scale {
	if (!CGPointEqualToPoint(_scale, scale)) {
		_scale = scale;
		[self setNeedsDisplay];
	}
}

- (void) setPositionFromCenter:(CGPoint) positionFromCenter {
	if (!CGPointEqualToPoint(_positionFromCenter, positionFromCenter)) {
		_positionFromCenter = positionFromCenter;
		[self setNeedsDisplay];
	}
}

- (void) setup {

	NSLog(@"GraphView setup");

	self.contentMode = UIViewContentModeRedraw;

	CGPoint defaultPositionFromCenter = {0, 0};

	CGPoint defaultScale = {1, 1};

	self.positionFromCenter = defaultPositionFromCenter;
	self.scale = defaultScale;
}

- (void) awakeFromNib {
	[self setup];
}

- (id)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}

+ (void) logPoint:(CGPoint) point withLabel:(NSString*) label {

	NSLog(@"%@ : [%g,%g]", label, point.x, point.y);
}

/**
* Calculates the corresponding gY.
* gX must be in the range [-boundsWidth/2, +boundsWidth/2].
* It takes into account: positionFromCenter and scale.
* [gX,gY] points are relative to the center of bounds.
*/
- (CGFloat) calculateGraphY:(CGFloat) gX {

	double x = (gX - self.positionFromCenter.x) / self.scale.x;
	double y = [self.dataSource valueOfFunctionFor:x];
	CGFloat gY = self.positionFromCenter.y - (CGFloat) y * self.scale.y;

//	NSLog(@"%g => %g ===> %g => %g", gX, x, y, gY);

	return gY;
}

/** Tells if the point is inside the bounds of this view */
- (BOOL) isInsideBounds:(CGPoint) pointRelativeToCenterOfBounds {

/*
	NSLog(@"Point [%g,%g] inside bounds [%g,%g]+[%g,%g] ?",
			point.x, point.y,
			self.bounds.origin.x, self.bounds.origin.y,
			self.bounds.size.width, self.bounds.size.height);
*/
	// TODO: If bounds don't change we could store width and height in constants
	// TODO: We won't use points outside width so we could skip that check and only check height

	return pointRelativeToCenterOfBounds.x >= -self.bounds.size.width/2
			&& pointRelativeToCenterOfBounds.x <= self.bounds.size.width
			&& pointRelativeToCenterOfBounds.y >= -self.bounds.size.height/2
			&& pointRelativeToCenterOfBounds.y <= self.bounds.size.height/2;
}

- (void) drawGraphIn:(CGContextRef) context {

	UIGraphicsPushContext(context);

	CGContextSetLineWidth(context, 1.0);
	[[UIColor blueColor] setStroke];

	const CGFloat boundsHalfWidth = self.bounds.size.width / 2;

	CGPoint centerOfBounds = {
			self.bounds.origin.x + self.bounds.size.width/2,
			self.bounds.origin.y + self.bounds.size.height/2 };

	CGPoint current = { -boundsHalfWidth, [self calculateGraphY:-boundsHalfWidth] };

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, current.x, current.y);
	BOOL strokeNeeded = NO;

	const CGFloat precision = 1; // Increase number to draw less lines (reduce precision)

	for (CGFloat gX = -boundsHalfWidth + precision; gX <= boundsHalfWidth; gX += precision) {

		CGPoint next = { gX, [self calculateGraphY:gX] };

		if ([self isInsideBounds:current] || [self isInsideBounds:next]) {
//			NSLog(@"Add line to [%g,%g]", next.x, next.y);
			CGContextAddLineToPoint(context, centerOfBounds.x + next.x, centerOfBounds.y + next.y);
			strokeNeeded = YES;
		} else {
//			NSLog(@"Move to [%g,%g]", next.x, next.y);
			// Optimization: don't draw lines if current and next are outside the bounds
			if (strokeNeeded) {
				strokeNeeded = NO;
				CGContextStrokePath(context);
			}
			CGContextMoveToPoint(context, centerOfBounds.x + next.x, centerOfBounds.y + next.y);
		}

		current = next;
	}

	if (strokeNeeded) CGContextStrokePath(context);

	UIGraphicsPopContext();
}

- (void) drawAxes {
	CGPoint axesOrigin = {
			self.positionFromCenter.x + self.bounds.size.width/2,
			self.positionFromCenter.y + self.bounds.size.height/2};
	[AxesDrawer drawAxesInRect:self.bounds originAtPoint:axesOrigin scale:self.scale.x];
}

- (void)drawRect:(CGRect)rect
{
	NSLog(@"Redrawing...");
	[GraphView logPoint:self.scale withLabel:@"Scale"];
	[GraphView logPoint:self.positionFromCenter withLabel:@"Position from center"];

	CGContextRef context = UIGraphicsGetCurrentContext();

	[self drawAxes];
	//	[self drawAxesIn:context];

	[self drawGraphIn:context];
}

- (void) pinch:(UIPinchGestureRecognizer*) gesture {

	if (gesture.state == UIGestureRecognizerStateEnded) {

		// TODO: Is it possible to change x and y scales independently?
		CGPoint newScale = { self.scale.x * gesture.scale, self.scale.y * gesture.scale };
		self.scale = newScale;

		gesture.scale = 1;
	}
}

- (void) pan:(UIPanGestureRecognizer*) gesture {

	if (gesture.state == UIGestureRecognizerStateEnded) {

		const CGPoint translation = [gesture translationInView:self];

		[GraphView logPoint:self.positionFromCenter withLabel:@"Old position"];

		CGPoint newPosition = {
				self.positionFromCenter.x + translation.x, self.positionFromCenter.y + translation.y };
		self.positionFromCenter = newPosition;

		[GraphView logPoint:self.positionFromCenter withLabel:@"New position"];

		[gesture setTranslation:CGPointZero inView:self];
	}
}

/*
- (void) drawAxesIn:(CGContextRef) context {

	UIGraphicsPushContext(context);

	CGContextSetLineWidth(context, 1.0);
	[[UIColor grayColor] setStroke];

	const CGFloat xAxisPosition =
			self.bounds.origin.y + self.bounds.size.height/2 + [self positionFromCenter].y;

	const CGFloat yAxisPosition =
			self.bounds.origin.x + self.bounds.size.width/2 + [self positionFromCenter].x;

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, self.bounds.origin.x, xAxisPosition);
	CGContextAddLineToPoint(context, self.bounds.origin.x + self.bounds.size.width, xAxisPosition);
	CGContextStrokePath(context);

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, yAxisPosition, self.bounds.origin.y);
	CGContextAddLineToPoint(context, yAxisPosition, self.bounds.origin.y + self.bounds.size.height);
	CGContextStrokePath(context);

	UIGraphicsPopContext();
}
*/

@end
