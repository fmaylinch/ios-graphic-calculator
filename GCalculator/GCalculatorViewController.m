//
//  GCalculatorViewController.m
//  Calculator
//
//  Created by Ferran Maylinch Carrasco on 03/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GCalculatorViewController.h"
#import "CalculatorBrain.h"

@interface GCalculatorViewController ()

@property (nonatomic, strong) CalculatorBrain * brain;
@property (nonatomic) BOOL userIsTypingANumber;
@property (nonatomic, strong) NSMutableDictionary * variables;

@end


@implementation GCalculatorViewController

@synthesize display = _display;
@synthesize expressionDisplay = _expressionDisplay;
@synthesize variablesDisplay = _variablesDisplay;
@synthesize brain = _brain;
@synthesize userIsTypingANumber = _userIsTypingANumber;
@synthesize variables = _variables;


- (CalculatorBrain*) brain {
	if (!_brain) _brain = [[CalculatorBrain alloc] init];
	return _brain;
}

- (NSMutableDictionary*) variables {
	if (!_variables) _variables = [[NSMutableDictionary alloc] init];
	return _variables;
}

- (void) setUserIsTypingANumber :(BOOL) userIsTypingANumber {
    
	_userIsTypingANumber = userIsTypingANumber;
    
	// Change the display color to blue so the user knows he is typing a number.
    
	if (_userIsTypingANumber) {
		self.display.textColor = [UIColor blueColor];
	} else {
		self.display.textColor = [UIColor blackColor];
	}
    
	[self refreshVariablesDisplay];
}

- (IBAction) digitPressed :(UIButton*) sender {
    
	NSString* digit = [sender currentTitle];
    
	if (self.userIsTypingANumber) {
		// Avoid typing more than one "0"
		if (![self.display.text isEqualToString:@"0"] || ![digit isEqualToString:@"0"]) {
			self.display.text = [self.display.text stringByAppendingString:digit];
		}
	} else {
		self.display.text = digit;
		self.userIsTypingANumber = YES;
	}
}

- (IBAction) dotPressed {
    
	if (self.userIsTypingANumber) {
		// Avoid more than one dot
		if ([self.display.text rangeOfString:@"."].location == NSNotFound) {
			self.display.text = [self.display.text stringByAppendingString:@"."];
		}
	} else {
		self.display.text = @"0.";
		self.userIsTypingANumber = YES;
	}
}

- (IBAction) operationPressed :(UIButton*) sender {
    
	// Help the user and "press enter" automatically
	if (self.userIsTypingANumber) [self enterPressed];
    
	NSString* operation = [sender currentTitle];
    
	[self.brain pushOperatorOrVariable:operation];
    
	[self recalculateProgram];
}

/**
 If the user is typing a number, changes the sign of the number
 being typed. Otherwise executes the "change sign" as an operation.
 */
- (IBAction) signPressed :(UIButton*) sender {
    
	if (self.userIsTypingANumber) {
        
		double doubleValue = -[self.display.text doubleValue];
		NSString* resultText = [NSString stringWithFormat:@"%g", doubleValue];
		self.display.text = resultText;
        
	} else {
		return [self operationPressed:sender];
	}
}

- (IBAction) enterPressed {
    
	[self.brain pushOperand:[self.display.text doubleValue]];
	self.userIsTypingANumber = NO;
    
	[self recalculateProgram];
}

- (IBAction) clearPressed {
    
	[self.brain clearProgram];
	self.userIsTypingANumber = NO;
	self.display.text = @"0";
	self.expressionDisplay.text = @"";
}

- (IBAction) backspacePressed {
    
	if (self.userIsTypingANumber) {
        
		self.display.text = [self.display.text substringToIndex:self.display.text.length - 1];
        
		// Reset display in case the user removed everything or left only a "0"
		if (self.display.text.length == 0 || [self.display.text isEqualToString:@"0"]) {
			self.display.text = @"0";
			self.userIsTypingANumber = NO;
		}
	} else {
        
		[self.brain popElement];
		[self recalculateProgram];
	}
}

- (IBAction) variablePressed :(UIButton*) sender {
    
	NSString* variable = [sender currentTitle];
    
	if (self.userIsTypingANumber) {
		const double value = [self.display.text doubleValue];
		[self.variables setObject:[NSNumber numberWithDouble:value] forKey:variable];
		self.userIsTypingANumber = NO;
		[self recalculateProgram];
	} else {
		[self.brain pushOperatorOrVariable:variable];
		[self recalculateProgram];
	}
}

/**
 * Removes all the variable values
 */
- (IBAction) resetVariablesPressed {
    
	self.variables = nil;
	[self recalculateProgram];
}

/**
 * Recalculates the program result and refreshes the displays
 */
- (void) recalculateProgram {
    
	double result = [self.brain runProgramUsingVariables:self.variables];
	NSString* resultText = [NSString stringWithFormat:@"%g", result];
	self.display.text = resultText;
    
	[self refreshVariablesDisplay];
	[self refreshExpressionDisplay];
}

/**
 * Displays the expression in the calculator brain
 */
- (void) refreshExpressionDisplay {
    
	self.expressionDisplay.text = [self.brain descriptionOfProgram];
}

/**
 * Displays the variables used in the expression or (if the user is typing a number)
 * a help message so the user knows that the number can be assigned to a variable.
 */
- (void) refreshVariablesDisplay {
    
	if (self.userIsTypingANumber) {
		self.variablesDisplay.text = @"Press a letter to assign the number";
	} else {
		self.variablesDisplay.text = [NSString stringWithFormat:@"%@ (used: %@)",
                                      [self.variables description], [self.brain variablesUsedInProgram]];
        
		self.variablesDisplay.text = @"";
        
		for (NSString* variable in [self.brain variablesUsedInProgram]) {
            
			NSNumber* value = [self.variables objectForKey:variable];
            
			self.variablesDisplay.text = [self.variablesDisplay.text
                                          stringByAppendingString:[NSString stringWithFormat:@"%@=%@ ", variable, value]];
		}
	}
}

@end
