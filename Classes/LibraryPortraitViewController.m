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

@implementation LibraryPortraitViewController

@synthesize dataController;
@synthesize sBar;
@synthesize landscapeViewController;
@synthesize fetchedResultsController = _fetchedResultsController;
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

-(void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data", @"Error loading data") 
                                                        message:[NSString stringWithFormat:@"Error was: %@, quitting.", [error localizedDescription]]
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                              otherButtonTitles:nil];
        [alert show];
		
	}
	
	
//	self.dataController = [[DataController alloc] init];
	
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
	
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification object:nil];
	
	
	
	// Display navigation bar for this view controller.

	self.title = @"Library";
	UIBarButtonItem *libraryButton = [[[UIBarButtonItem alloc] initWithTitle:@"Filters" 
																   style:UIBarButtonItemStyleBordered 
																  target:self 
																  action:@selector(filterAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = libraryButton;
}


- (void)viewDidUnload {
    self.landscapeViewController = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [landscapeViewController release];
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
	NSString *alertString;
	
	alertString = @"Sample images included in this project are all in the public domain, courtesy of NASA.";
	UIAlertView *infoAlertPanel = [[UIAlertView alloc] initWithTitle:@"OpenFlow Demo App" 
															 message:[NSString stringWithFormat:@"%@\n\nFor more info about the OpenFlow API, visit apparentlogic.com.", alertString]
															delegate:nil 
												   cancelButtonTitle:nil 
												   otherButtonTitles:@"Dismiss", nil];
	[infoAlertPanel show];
	[infoAlertPanel release];
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

	return cell;
}


- (NSString *)tableView:(UITableView *)tableView  titleForHeaderInSection:(NSInteger)section {
    // Display the dates as section headings.
    return [[[[self fetchedResultsController] sections] objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CardViewController * viewController = [[CardViewController alloc] init];
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	viewController.card = card;
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
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // The typecast on the next line is not ordinarily necessary, however without it, we get a warning about
    // the returned object not conforming to UITabBarDelegate. The typecast quiets the warning so we get
    // a clean build.
    UrzasFactoryAppDelegate *appDelegate = (UrzasFactoryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:managedObjectContext];
    
        
    NSString *sectionKey = nil;
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"expansion.name" ascending:YES];
	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
            [fetchRequest setSortDescriptors:sortDescriptors];
            [sortDescriptor1 release];
            [sortDescriptor2 release];
            [sortDescriptors release];
            sectionKey = @"expansion.name";
   	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:20];
    
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest    
                                                                          managedObjectContext:managedObjectContext 
                                                                            sectionNameKeyPath:sectionKey
                                                                                     cacheName:@"Card"];
    frc.delegate = self;
    _fetchedResultsController = frc;
    
	[fetchRequest release];
    
	return _fetchedResultsController;
}  
@end

