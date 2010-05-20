//
//  LibraryPortraitViewController.m
//  UrzasFactory
//
//  Created by Jeremy Lyman on 4/26/10.
//  Copyright 2010 Jeremy Lyman. All rights reserved.
//

#import "LibraryPortraitViewController.h"
#import "LibraryLandscapeViewController.h"
#import "UFView.h"
#import "DataController.h"
#import "UrzasFactoryAppDelegate.h"
#import "Card.h"
#import "CardViewController.h"
#import "Deck.h"

@implementation LibraryPortraitViewController

@synthesize tView;
@synthesize sBar;
@synthesize fetchRequest;
@synthesize landscapeViewController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize predicateDictionary;
@synthesize delegate, deck;

-(void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];	
	
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
                                                        message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                              otherButtonTitles:nil];
        [alert show];
		
	}
	[self.tView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated {
	self.fetchedResultsController = nil;
	self.fetchRequest = nil;
}
- (void)viewDidLoad {
	NSError *error = nil;
	fetchOffset = 0;
	self.fetchRequest = nil;
	self.fetchedResultsController = nil;
	
	if (![[self fetchedResultsController] performFetch:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
                                                        message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                              otherButtonTitles:nil];
        [alert show];
		
	}
	

	
	// create and configure the view
	//UFView * deckView = [[UFView alloc] initWithFrame:self.navigationController.view.frame];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backdropBottom.png"]];
	
//	CGRect cgRct = CGRectMake(10, 10, 300, 400); //define size and position of view
//	UITableView * tableView = [[UITableView alloc] initWithFrame:cgRct style:UITableViewStyleGrouped];
//	tableView.dataSource = self;
//	tableView.delegate = self; //make the current object the event handler for view
//	tableView.backgroundColor = [UIColor clearColor];
	
	//self.view = deckView;
	//[deckView release];
//	[self.view addSubview:tableView];
//	[tableView release];
	
    LibraryLandscapeViewController *viewController = [[LibraryLandscapeViewController alloc]
											   initWithNibName:@"LibraryLandscapeView" bundle:nil];
    self.landscapeViewController = viewController;
    [viewController release];
	
	
	
	
	// Display navigation bar for this view controller.

	if (self.deck != nil && self.delegate != nil) {
		self.title = @"Add to Deck";
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
																		 style:UIBarButtonItemStyleBordered 
																		target:self 
																		action:@selector(cancel)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
	} else {
		self.title = @"Library";
		UIBarButtonItem *libraryButton = [[UIBarButtonItem alloc] initWithTitle:@"Filters" 
																		  style:UIBarButtonItemStyleBordered 
																		 target:self 
																		 action:@selector(filterAction:)];
		self.navigationItem.rightBarButtonItem = libraryButton;
		[libraryButton release];
	}

}

- (void)cancel {
	[self.delegate cancel];
}
- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

	self.delegate = nil;
	self.deck = nil;
    self.landscapeViewController = nil;
}

- (void)dealloc {
    [landscapeViewController release];
	[fetchRequest release];
    [super dealloc];	
}

- (void)orientationChanged:(NSNotification *)notification {
    // We must add a delay here, otherwise we'll swap in the new view
    // too quickly and we'll get an animation glitch
    [self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
}

- (void)updateLandscapeView
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView) {
        [self presentModalViewController:self.landscapeViewController animated:YES];
        isShowingLandscapeView = YES;
    } else if (deviceOrientation == UIDeviceOrientationPortrait && isShowingLandscapeView) {
		[self dismissModalViewControllerAnimated:YES];
        isShowingLandscapeView = NO;
    }    
}

- (void)filterAction:(id)sender {
	FilterViewController *filterView = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
	filterView.delegate = self;
	
	UINavigationController *filterNavigationController = [[UINavigationController alloc] initWithRootViewController:filterView];
	
	[self presentModalViewController:filterNavigationController animated:YES];
	
	[filterNavigationController release];
	[filterView release];
}

- (void) updatePredicateDictionary:(NSMutableDictionary *)buttonStateDictionary {
	// Key manaType Value YES/NO
	predicateDictionary = [buttonStateDictionary copy];
}

- (void) modalDialogFinished:(id)sender {
	// Refresh the Table
	[self refreshTableData];
	// Release the Modal View
	[self dismissModalViewControllerAnimated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait); // support only portrait
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[self.fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
	
    return count;	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Try to get rusable cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
	if (cell == nil) {
		//If not possible create a new cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"] 
				autorelease];
	}

	cell.backgroundColor = [UIColor colorWithHue:0 saturation:0.5 brightness:0.5 alpha:0.5];
	cell.layer.masksToBounds = YES;
	cell.layer.cornerRadius = 15.0;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.textLabel setText:[card valueForKey:@"name"]];
	
	NSLog(@"Card with name %@: %@",[card valueForKey:@"name"], card);

	return cell;
}

// Header titles
- (NSString *)tableView:(UITableView *)tableView  titleForHeaderInSection:(NSInteger)section {
    // Display the dates as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

// Selecting an item on the table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

	CardViewController * viewController = [[CardViewController alloc] init];
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	viewController.card = card;
	viewController.deck = self.deck;
	viewController.delegate = self.delegate;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSFetchedResultsController *)fetchedResultsController {
   
	if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
	
    // The typecast on the next line is not ordinarily necessary, however without it, we get a warning about
    // the returned object not conforming to UITabBarDelegate. The typecast quiets the warning so we get
    // a clean build.
    UrzasFactoryAppDelegate *appDelegate = (UrzasFactoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
	//predicateDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"manas.name", @"Green", nil];
        
    NSString *sectionKey = nil;
	self.fetchRequest = [DataController requestForEntityNamed:@"Card" 
								  containingKeyAndValues:predicateDictionary
												 usingOR:YES 
									 withSortDescriptors:[NSArray arrayWithObjects:@"expansion.name", @"name", nil] 
											   inContext:managedObjectContext];
	[fetchRequest setFetchBatchSize:15];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setResultType:NSManagedObjectResultType]; // NSDictionaryResultType];
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"name", @"expansion", nil]];
	[fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"manaItems"]];
	sectionKey = @"expansion.name";
    
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest    
                                                                          managedObjectContext:managedObjectContext 
                                                                            sectionNameKeyPath:sectionKey
                                                                                     cacheName:@"Card"];
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
	return _fetchedResultsController;
}  

- (void)refreshTableData {
	// Refresh the Table
	NSError *error = nil;
	
//	[fetchRequest setPredicate:[DataController predicateContainingKeyAndValues:predicateDictionary usingOR:YES]];
	
	if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
                                                        message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                              otherButtonTitles:nil];
        [alert show];
		
	}
	
	[tView reloadData];
}

@end

