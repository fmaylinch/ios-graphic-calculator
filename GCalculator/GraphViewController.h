//
//  GraphicViewController.h
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@class CalculatorBrain;

@interface GraphViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic, weak) CalculatorBrain* brain;

@end
