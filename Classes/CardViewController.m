    //
//  CardViewController.m
//  UrzasFactory
//
//  Created by Cameron Knight on 4/28/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import "CardViewController.h"
#import "Card.h"
#import "Deck.h"
#import "CardItem.h"
#import "UrzasFactoryAppDelegate.h"
#import "DeckViewController.h"

@implementation CardViewController

@synthesize card, fields, deck, delegate, tableView = _tableView;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.delegate = self;
	NSArray * keys = [NSArray arrayWithObjects:
					  @"flavor",
					  @"power",
					  @"multiverseID",
					  @"convertedManaCost",
					  @"text",
					  @"toughness",
					  @"loyalty",
					  @"name",
					  @"rarity",
//					  @"otherSets",
//					  @"manas",
//					  @"decks",
//					  @"type",
//					  @"expansion",
//					  @"artist",
					  nil];
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	for (id key in keys) {
		if ([card valueForKey:key]) {
			NSLog(@"%@ - %@", key, [card valueForKey:key]);
			[dict setValue:[card valueForKey:key] forKey:key];
		}
	}
	self.fields = dict;
	[self.tableView reloadData];
	if (self.deck != nil && self.delegate != nil) {
		self.title = @"Add Card";
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" 
																		 style:UIBarButtonItemStyleBordered 
																		target:self 
																		action:@selector(addCard)];
		self.navigationItem.rightBarButtonItem = addButton;
		[addButton release];
	}
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backdropBottom.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)addCard {
	UrzasFactoryAppDelegate *appDelegate = (UrzasFactoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	CardItem* cardItem = (CardItem*)[NSEntityDescription insertNewObjectForEntityForName:@"CardItem" inManagedObjectContext:managedObjectContext];
	
	cardItem.card = self.card;
	cardItem.quantity = [NSNumber numberWithInt:1];
	cardItem.deck = self.deck;
	// Commit the change.
	[(DeckViewController*)self.delegate addedCard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	if (card.name) self.title = card.name;
	else self.title = @"Card";
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.delegate = nil;
	self.deck = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"COUNT: %d",[fields count]);
    return [fields count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0.5 brightness:0.5 alpha:0.5];
	NSString * text = nil;
	NSString * detail = nil;
	
	text = [[[fields allKeys] objectAtIndex:indexPath.row] description];
	
	if ([[[fields allValues] objectAtIndex:indexPath.row] isKindOfClass:[NSData class]]) {
		NSString *stringFromData = [[NSString alloc]  initWithBytes:[[[fields allValues] objectAtIndex:indexPath.row] bytes]
															 length:[[[fields allValues] objectAtIndex:indexPath.row] length] 
														   encoding:NSUTF8StringEncoding];
		detail = [NSString stringWithString:stringFromData];
		[stringFromData release];

	} else {
		detail = [NSString stringWithString:[[[fields allValues] objectAtIndex:indexPath.row] description]];
	}
	
	cell.textLabel.text = text;
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.text = detail;
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	//	cell.imageView.image = [UIImage imageNamed:@"Icon.png"];
    // Set up the cell...
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView  titleForHeaderInSection:(NSInteger)section {
    // Display the dates as section headings.
    return nil;//[[[[self fetchedResultsController] sections] objectAtIndex:section] name];
}

@end
