//
//  DecksViewController.m
//  UrzasFactory
//
//  Created by Cameron Knight on 2/25/10.
//  Copyright 2010 Moblico. All rights reserved.


#import "DecksViewController.h"
#import "DeckViewController.h"
#import "UrzasFactoryAppDelegate.h"
#import "UFView.h"

@implementation DecksViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize newManagedObjectContext = _newManagedObjectContext;

- (void)viewDidLoad {
	self.title = @"Decks";
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [super viewDidLoad];
}

- (void)insertNewObject {
    NewDeckViewController * newDeckViewController = [[NewDeckViewController alloc] initWithNibName:@"NewDeckViewController" bundle:nil];
	newDeckViewController.delegate = self;
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
	self.newManagedObjectContext = newContext;
	[newContext release];

    [self.newManagedObjectContext setPersistentStoreCoordinator:[[self.fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
    newDeckViewController.deck = (Deck*)[NSEntityDescription insertNewObjectForEntityForName:@"Deck" inManagedObjectContext:self.newManagedObjectContext];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newDeckViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[newDeckViewController release];
	[navController release];	
}

- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		/*
		 The new book is associated with the add controller's managed object context.
		 This is good because it means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad -- but it does make it more difficult to get the new book registered with the fetched results controller.
		 First, you have to save the new book.  This means it will be added to the persistent store.  Then you can retrieve a corresponding managed object into the application delegate's context.  Normally you might do this using a fetch or using objectWithID: -- for example
		 
		 NSManagedObjectID *newBookID = [controller.book objectID];
		 NSManagedObject *newBook = [applicationContext objectWithID:newBookID];
		 
		 These techniques, though, won't update the fetch results controller, which only observes change notifications in its context.
		 You don't want to tell the fetch result controller to perform its fetch again because this is an expensive operation.
		 You can, though, update the main context using mergeChangesFromContextDidSaveNotification: which will emit change notifications that the fetch results controller will observe.
		 To do this:
		 1	Register as an observer of the add controller's change notifications
		 2	Perform the save
		 3	In the notification method (addControllerContextDidSave:), merge the changes
		 4	Unregister as an observer
		 */
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;
	
	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger count = [[self.fetchedResultsController sections] count];
    return (count == 0) ? 1 : count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
    return count;	
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"name"] description];
    cell.detailTextLabel.text = [[managedObject valueForKey:@"text"] description];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor colorWithHue:0 saturation:0.5 brightness:0.5 alpha:0.5];

	[self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView  titleForHeaderInSection:(NSInteger)section {
    // Display the dates as section headings.
    return [[[[self fetchedResultsController] sections] objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	DeckViewController *deckViewController = [[DeckViewController alloc] initWithNibName:@"DeckView" bundle:nil];
	deckViewController.deck = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.navigationController pushViewController:deckViewController animated:YES];
	[deckViewController release];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


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
	
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:managedObjectContext];
    
	
//    NSString *sectionKey = nil;
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//	NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
//	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptor1 release];
//	[sortDescriptor2 release];
	[sortDescriptors release];
//	sectionKey = @"expansion.name";
   	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:20];
    
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest    
                                                                          managedObjectContext:managedObjectContext 
                                                                            sectionNameKeyPath:nil
                                                                                     cacheName:@"Deck"];
    frc.delegate = self;
    _fetchedResultsController = frc;
    
	[fetchRequest release];
    
	return _fetchedResultsController;
}  

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}


@end
