//
//  NewDeckViewController.m
//  UrzasFactory
//
//  Created by Cameron Knight on 5/12/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import "NewDeckViewController.h"
#import "Deck.h"

@implementation NewDeckViewController

@synthesize delegate, deck, textView, textField, imageView, textViewCell, textFieldCell, tableView = _tableView;

#pragma mark -
#pragma mark View lifecycle

- (IBAction)cancel:(id)sender {
	[delegate newDeckViewController:self didFinishWithSave:NO];
}

- (IBAction)save:(id)sender {
	deck.name = self.textField.text;
	deck.text = self.textView.text;
	[delegate newDeckViewController:self didFinishWithSave:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    // Override the DetailViewController viewDidLoad with different navigation bar items and title.
    self.title = @"New Deck";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																							target:self action:@selector(save:)] autorelease];
	
	// Set up the undo manager and set editing state to YES.
	self.editing = YES;
	UIImage * image = [UIImage imageNamed:@"TextViewBorder.png"];
	self.imageView.image = [image stretchableImageWithLeftCapWidth:15.0 topCapHeight:15.0];
//	cell.backgroundColor = [UIColor colorWithHue:0 saturation:0.5 brightness:0.5 alpha:0.5];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.textFieldCell.backgroundColor = [UIColor colorWithHue:0 saturation:0.5 brightness:0.5 alpha:0.5];
	self.textViewCell.backgroundColor = [UIColor colorWithHue:0 saturation:0.5 brightness:0.5 alpha:0.5];
	self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.tableView.backgroundColor = [UIColor clearColor];
	[self.textField becomeFirstResponder];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 1) {
		return 119.0;
	}
	return 62.0;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
		return self.textFieldCell;
	}
    return self.textViewCell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
}


- (void)dealloc {
    [super dealloc];
}


@end

