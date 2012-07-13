//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Ferran Maylinch Carrasco on 28/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()

@property (nonatomic, strong) NSMutableArray* programStack;

@end


@implementation CalculatorBrain

@synthesize programStack = _programStack;

/**
* NSDictionary where the keys are the operators and the values are the number of their operands.
* If the stack element is here, it is an operator (and you can get the number of its operands).
*/
static NSDictionary* operators;

+ (void) initialize {

//	[super initialize];

	operators = [NSDictionary
			dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInteger:2], @"+",
					[NSNumber numberWithInteger:2], @"-",
					[NSNumber numberWithInteger:2], @"*",
					[NSNumber numberWithInteger:2], @"/",
					[NSNumber numberWithInteger:1], @"sin",
					[NSNumber numberWithInteger:1], @"cos",
					[NSNumber numberWithInteger:1], @"sqrt",
					[NSNumber numberWithInteger:1], @"+/-",
					[NSNumber numberWithInteger:0], @"π",
					nil];
}


- (NSMutableArray*) programStack {

	if (!_programStack) _programStack = [[NSMutableArray alloc] init];
	return _programStack;
}

- (void) pushOperand :(double) operand {

	[self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void) pushOperatorOrVariable :(NSString*) operatorOrVariable {

	[self.programStack addObject:operatorOrVariable];
}

- (id) popElement {

	return [CalculatorBrain popElementFromStack:self.programStack];
}

/** Calculates the result of the program in the stack, using the specified variables */
- (double) calculateProgram :(NSMutableArray*) stack using:(NSDictionary*) variables {

	double result = 0;

	id element = [CalculatorBrain popElementFromStack:stack];

	if ([element isKindOfClass:[NSNumber class]]) {

		result = [element doubleValue];

	} else if ([element isKindOfClass:[NSString class]]) {

		NSString* operation = element;

		if ([operation isEqualToString:@"+"]) {
			result = [self calculateProgram:stack using:variables] + [self calculateProgram:stack using:variables];
		} else if ([operation isEqualToString:@"-"]) {
			double temp = [self calculateProgram:stack using:variables];
			result = [self calculateProgram:stack using:variables] - temp;
		} else if ([operation isEqualToString:@"*"]) {
			result = [self calculateProgram:stack using:variables] * [self calculateProgram:stack using:variables];
		} else if ([operation isEqualToString:@"/"]) {
			double temp = [self calculateProgram:stack using:variables];
			result = [self calculateProgram:stack using:variables] / temp;
		} else if ([operation isEqualToString:@"sin"]) {
			result = sin([self calculateProgram:stack using:variables]);
		} else if ([operation isEqualToString:@"cos"]) {
			result = cos([self calculateProgram:stack using:variables]);
		} else if ([operation isEqualToString:@"sqrt"]) {
			result = sqrt([self calculateProgram:stack using:variables]);
		} else if ([operation isEqualToString:@"π"]) {
			result = M_PI;
		} else if ([operation isEqualToString:@"+/-"]) {
			result = -[self calculateProgram:stack using:variables];
		} else {
			// If the operator is unknown, we suppose it's a variable
			NSString* const variable = operation;
			result = [[variables objectForKey:variable] doubleValue];
		}
	}

	return result;
}

- (double) runProgramUsingVariables :(NSDictionary*) variables {

	NSMutableArray* stack = [self.programStack mutableCopy];

	return [self calculateProgram:stack using:variables];
}

- (NSString*) descriptionOfProgram {

	NSMutableArray* const program = [self.programStack mutableCopy];

	NSMutableString* description = [[NSMutableString alloc] init];

	while ([program count] > 0) {
		[self appendDescriptionOf: program into: description addBrackets:NO];
		if ([program count] > 0) [description appendString:@", "];
	}

	return description;
}

/**
* Appends the description of the program into the 'description' parameter,
* adding brackets when necessary
*/
- (void) appendDescriptionOf:(NSMutableArray*) programStack
						into:(NSMutableString*) description
				 addBrackets:(BOOL) addBrackets {

	id const element = [CalculatorBrain popElementFromStack:programStack];

	if (element) {

		NSNumber* const numberOfParameters = [operators objectForKey:element];
		if (numberOfParameters) {

			// Treat operators depending on their number of parameters
			const int numOfParams = [numberOfParameters intValue];

			NSString* op = element;

			if (numOfParams == 0) {
				[description appendString:op];
			} else if (numOfParams == 1) {
				if ([op isEqualToString:@"+/-"]) {
					[description appendString:@"-"]; // +/- operator is printed as -
				} else {
					[description appendString:op];
				}
				[description appendString:@"("];
				[self appendDescriptionOf:programStack into:description addBrackets:NO];
				[description appendString:@")"];
			} else if (numOfParams == 2) {
				NSMutableString* secondArgument = [[NSMutableString alloc] init];
				[self appendDescriptionOf:programStack into:secondArgument addBrackets:YES];
				if (addBrackets) [description appendString:@"("];
				[self appendDescriptionOf:programStack into:description addBrackets:YES];
				[description appendFormat:@" %@ %@", op, secondArgument];
				if (addBrackets) [description appendString:@")"];
			} else {
				NSLog(@"Unsupported number of parameters for operator '%@': %i", op, numOfParams);
			}
		} else {
			// Not an operator: it's a number or variable
			[description appendFormat:@"%@", element];
		}
	}
}

- (void) gatherVariablesFrom:(NSMutableArray*) stack into:(NSMutableSet*) variables {

	id element = [CalculatorBrain popElementFromStack:stack];

	if (element) {

		// If element is a NSString and is not an operator, it must be a variable
		if ([element isKindOfClass:[NSString class]] && ![operators objectForKey:element]) {
			[variables addObject:element];
		}

		[self gatherVariablesFrom:stack into:variables];
	}
}

- (NSSet*) variablesUsedInProgram {

	NSMutableArray* stack = [self.programStack mutableCopy];

	NSMutableSet* variables = [[NSMutableSet alloc] init];

	for (id element in self.programStack)

	[self gatherVariablesFrom:stack into:variables];

	if ([variables count] > 0) {
		return variables;
	} else {
		return nil;
	}
}

- (void) clearProgram {

	[self.programStack removeAllObjects];
}

/** Pops the last object from the stack (or returns nil if the stack is empty) */
+ (id) popElementFromStack: (NSMutableArray*) stack {

	id element = [stack lastObject];
	if (element) [stack removeLastObject];
	return element;
}

@end
