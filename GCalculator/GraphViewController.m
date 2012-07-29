//
//  GraphicViewController.m
//  GCalculator
//
//  Created by Ferran Maylinch Carrasco on 14/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"
#import "GraphUtil.h"

@interface GraphViewController () <FunctionDataSource>

@property (nonatomic, weak) IBOutlet GraphView* graphView;
@property (nonatomic, strong) NSMutableDictionary* variables;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation GraphViewController

@synthesize brain = _brain;
@synthesize graphView = _graphView;
@synthesize variables = _variables;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;


// --------------------------- SETUP ---------------------------

- (void) viewWillAppear: (BOOL) animated {
	[super viewWillAppear:animated];
	NSLog(@"GraphViewController viewWillAppear");
	[GraphUtil logPoint:self.graphView.bounds.origin withLabel:@"Bounds origin"];
	[self.graphView boundsInitialized];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	NSLog(@"GraphViewController viewDidLoad");
	[GraphUtil logPoint:self.graphView.bounds.origin withLabel:@"Bounds origin"];
}


- (void) setup {
	NSLog(@"GraphViewController setup");
	self.variables = [[NSMutableDictionary alloc] init];
}

- (void) awakeFromNib {
	NSLog(@"GraphViewController awakeFromNib");
	[self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"GraphViewController initWithNibName");
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

- (void) setSplitViewBarButtonItem:(UIBarButtonItem*) splitViewBarButtonItem {

	if (_splitViewBarButtonItem != splitViewBarButtonItem) {

		NSMutableArray* const toolbarItems = [self.toolbar.items mutableCopy];
		if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
		if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
		self.toolbar.items = toolbarItems;
		_splitViewBarButtonItem = splitViewBarButtonItem;
	}
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


- (void)viewDidUnload {
    [self setToolbar:nil];
    [super viewDidUnload];
}
@end
