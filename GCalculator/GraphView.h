//
//  GraphicView.h
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FunctionDataSource
- (double) valueOfFunctionFor: (double) x;
@end

@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id <FunctionDataSource> dataSource;

/** Scale of the graph (X and Y) */
@property (nonatomic) CGPoint scale;

/** Position of the graph */
@property (nonatomic) CGPoint positionFromCenter;

+ (void) logPoint:(CGPoint) point withLabel:(NSString*) string;
@end
