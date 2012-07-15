//
//  GraphicViewController.h
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalculatorBrain;

@interface GraphViewController : UIViewController

@property (nonatomic, weak) CalculatorBrain* brain;

@end
