//
//  GraphicViewController.m
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"

@interface GraphViewController () <FunctionDataSource>

@property (nonatomic, weak) IBOutlet GraphView* graphView;
@property (nonatomic, strong) NSMutableDictionary* variables;

@end

@implementation GraphViewController

@synthesize brain = _brain;
@synthesize graphView = _graphView;
@synthesize variables = _variables;


// --------------------------- SETUP ---------------------------

- (void) setup {
	NSLog(@"GraphViewController setup");
	self.variables = [[NSMutableDictionary alloc] init];
}

- (void) awakeFromNib {
	[self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self setup];
	}
    return self;
}


// --------------------------- G/SETTERS ---------------------------

- (void) setBrain: (CalculatorBrain*) brain {
	_brain = brain;
	[self.graphView setNeedsDisplay];
}

- (void) setGraphView:(GraphView*) graphView {

	NSLog(@"Setting GraphView");
	_graphView = graphView;

	self.graphView.dataSource = self;

	[self.graphView addGestureRecognizer:
			[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
	[self.graphView addGestureRecognizer:
			[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];

	UITapGestureRecognizer* const tripleTapGestureRecognizer =
			[[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
	tripleTapGestureRecognizer.numberOfTapsRequired = 3;

	[self.graphView addGestureRecognizer:
			tripleTapGestureRecognizer];
}


// --------------------------- VIEW SETTINGS ---------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return YES;
}


// ---------------------- FunctionDataSource protocol ----------------------

- (double) valueOfFunctionFor:(double) x {

	[self.variables setObject:[NSNumber numberWithDouble:x] forKey:@"x"];

//	NSLog(@"Calculating program for value: %g", x);

	return [self.brain runProgramUsingVariables:self.variables];
}


@end
