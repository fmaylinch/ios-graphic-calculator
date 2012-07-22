//
//  GCalculatorViewController.h
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 13/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCalculatorViewController : UIViewController <UISplitViewControllerDelegate>

/** Display for the results and the numbers being typed */
@property (weak, nonatomic) IBOutlet UILabel *display;

/** Display for the program expression */
@property (weak, nonatomic) IBOutlet UILabel *expressionDisplay;

@end
