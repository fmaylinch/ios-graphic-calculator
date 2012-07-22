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

- (void) setScale:(CGFloat) scale {
	if (_scale != scale) {
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
	CGFloat defaultScale = 1;

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


// --------------------------- DRAWING ---------------------------

- (void) drawRect : (CGRect)rect
{
	NSLog(@"Redrawing...");
	NSLog(@"Scale: %g", self.scale);
	[GraphView logPoint:self.positionFromCenter withLabel:@"Position from center"];

	CGContextRef context = UIGraphicsGetCurrentContext();

	[self drawAxes];

	[self drawGraphIn:context];
}

- (void) drawAxes
{
	CGPoint axesOrigin = {
			self.positionFromCenter.x + self.bounds.size.width/2,
			self.positionFromCenter.y + self.bounds.size.height/2};
	[AxesDrawer drawAxesInRect:self.bounds originAtPoint:axesOrigin scale:self.scale];
}

- (void) drawGraphIn : (CGContextRef) context
{
	UIGraphicsPushContext(context);

	CGContextSetLineWidth(context, 1.0);
	[[UIColor blueColor] setStroke];

	const CGFloat boundsHalfWidth = self.bounds.size.width / 2;

	CGPoint centerOfBounds = {
			self.bounds.origin.x + self.bounds.size.width/2,
			self.bounds.origin.y + self.bounds.size.height/2 };

	// Starting point of the graph. Relative to center of bounds, and real (= "relative" to screen)
	CGPoint relativeCurrent = { -boundsHalfWidth, [self calculateGraphY:-boundsHalfWidth] };
	CGPoint realCurrent = [GraphView transformPoint:relativeCurrent relativeTo:centerOfBounds];

	BOOL penDown = NO; // YES means we should add lines to path

	const CGFloat pointsPerPixel = 1 / self.contentScaleFactor;
	NSLog(@"pointsPerPixel: %g", pointsPerPixel);

	for (CGFloat gX = -boundsHalfWidth + pointsPerPixel; gX <= boundsHalfWidth; gX += pointsPerPixel) {

		CGPoint relativeNext = { gX, [self calculateGraphY:gX] };
		CGPoint realNext = [GraphView transformPoint:relativeNext relativeTo:centerOfBounds];

		if ([GraphView isPointReal:realNext]) {

			if ([self isInsideBounds:realCurrent] || [self isInsideBounds:realNext]) {

				// If pen was not down, try to start path (if current point is real)
				if (!penDown && [GraphView isPointReal:realCurrent]) {
					[GraphView logPoint:realCurrent withLabel:@"Starting path from"];
					CGContextBeginPath(context);
					CGContextMoveToPoint(context, realCurrent.x, realCurrent.y);
					penDown = YES;
				}

				// If pen is down, add line
				if (penDown) {

					[GraphView logPoint:realNext withLabel:@"Adding line to"];
					CGContextAddLineToPoint(context, realNext.x, realNext.y);

					// If we are outside the bounds, stroke path and raise the pen
					if (![self isInsideBounds:realNext]) {
						[GraphView logPoint:realNext withLabel:@"Stroking up to next point (outside of bounds)"];
						CGContextStrokePath(context);
						penDown = NO;
					}
				}
			}

		} else {

			// next point is not real, so finish the stroke if the pen was down
			if (penDown) {
				[GraphView logPoint:realCurrent withLabel:@"Stroking up to current point"];
				[GraphView logPoint:realNext withLabel:@"-> Next point is not real"];
				CGContextStrokePath(context);
				penDown = NO;
			}
		}

		realCurrent = realNext;
	}

	if (penDown) {
		[GraphView logPoint:realCurrent withLabel:@"Stroking to last point"];
		CGContextStrokePath(context);
	}

	UIGraphicsPopContext();
}


// ------------------- AUXILIARY FUNCTIONS FOR DRAWING -------------------

/**
* Calculates the corresponding graphic y (gY).
* The graphic x (gX) must be in the range [-boundsWidth/2, +boundsWidth/2] (0 means center of bounds).
* It takes into account: positionFromCenter and scale.
* [gX,gY] points are relative to the center of bounds (so [0,0] is the center of bounds).
*/
- (CGFloat) calculateGraphY:(CGFloat) gX {

	double x = (gX - self.positionFromCenter.x) / self.scale;
	double y = [self.dataSource valueOfFunctionFor:x];
	CGFloat gY = self.positionFromCenter.y - (CGFloat) y * self.scale;

//	NSLog(@"%g => %g ===> %g => %g", gX, x, y, gY);

	return gY;
}

/**
* Transforms a point that is relative to 'center' to a real point (relative to screen)
*/
+ (CGPoint) transformPoint:(CGPoint) relativePoint relativeTo:(CGPoint) center
{
	CGPoint realPoint = { relativePoint.x + center.x, relativePoint.y + center.y };
	return realPoint;
}

/**
* Tells if the point is inside the bounds of this view.
* It is useful to avoid adding lines outside the bounds.
*/
- (BOOL) isInsideBounds:(CGPoint) point
{
	return CGRectContainsPoint(self.bounds, point);
}

/**
* Returns YES if point coordinates are not inf or nan.
* It is useful because moving or adding lines to inf/nan points crashes the program.
*/
+ (BOOL) isPointReal:(CGPoint) point {

	return !isinf(point.x) && !isinf(point.y) && !isnan(point.x) && !isnan(point.y);
}

+ (void) logPoint:(CGPoint) point withLabel:(NSString*) label {

	NSLog(@"%@ : [%g,%g]", label, point.x, point.y);
}


// --------------------------- GESTURES ---------------------------

/** Pinch changes scale */
- (void) pinch : (UIPinchGestureRecognizer*) gesture {

	if (gesture.state == UIGestureRecognizerStateEnded) {

		NSLog(@"Pinch scale: %g", gesture.scale);

		self.scale = self.scale * gesture.scale;
		gesture.scale = 1;
	}
}

/** Pan changes positionFromCenter */
- (void) pan : (UIPanGestureRecognizer*) gesture {

	if (gesture.state == UIGestureRecognizerStateEnded) {

		const CGPoint translation = [gesture translationInView:self];

		[GraphView logPoint:translation withLabel:@"Pan translation"];

		CGPoint newPosition = {
				self.positionFromCenter.x + translation.x, self.positionFromCenter.y + translation.y };
		self.positionFromCenter = newPosition;

		[gesture setTranslation:CGPointZero inView:self];
	}
}

// Triple tap moves the axes center to the location of the tap
- (void) tripleTap : (UITapGestureRecognizer*) gesture {

	if (gesture.state == UIGestureRecognizerStateEnded) {

		const CGPoint location = [gesture locationInView:self];
		[GraphView logPoint:location withLabel:@"Tap location"];

		const CGPoint newPosition =
				{ location.x - self.bounds.size.width/2, location.y - self.bounds.size.height/2 };
		self.positionFromCenter = newPosition;
	}
}

@end
