//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Ferran Maylinch Carrasco on 28/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorBrain : NSObject

/** Pushes an operand into the program stack */
- (void) pushOperand : (double) operand;

/** Pushes an operator or variable into the program stack */
- (void) pushOperatorOrVariable :(NSString*) operatorOrVariable;

/** Pops an element from the program stack (or returns nil if there are no more elements) */
- (id) popElement;

/** Runs current program using specified variables and returns the result */
- (double) runProgramUsingVariables :(NSDictionary*) variables;

/** Returns the variables used in the program (or nil if no variables are used) */
- (NSSet*) variablesUsedInProgram;

/** Clears the program */
- (void) clearProgram;

/** Returns a printable description of the current program */
- (NSString*) descriptionOfProgram;

@end
