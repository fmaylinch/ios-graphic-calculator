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

/** Scale of the graph */
@property (nonatomic) CGFloat scale;

/** Position of the graph relative to center of bound. {0,0} means center of bounds.  */
@property (nonatomic) CGPoint positionFromCenter;

- (void) boundsInitialized;
@end
