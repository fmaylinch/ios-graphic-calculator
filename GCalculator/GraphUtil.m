//
// Created by fmaylinch on 25/07/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GraphUtil.h"


@implementation GraphUtil

+ (void) logPoint:(CGPoint) point withLabel:(NSString*) label {

	NSLog(@"%@ : [%g,%g]", label, point.x, point.y);
}

@end