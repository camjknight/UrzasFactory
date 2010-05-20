//
//  DeckViewController.m
//  UrzasFactory
//
//  Created by Jeremy Lyman on 5/3/10.
//  Copyright 2010 Jeremy Lyman. All rights reserved.
//

#import "DeckViewController.h"
#import "DataController.h"
#import "CardViewController.h"
#import "UrzasFactoryAppDelegate.h"
#import "Deck.h"
#import "Card.h"
#import "Mana.h"
#import "ManaItem.h"
#import "CardItem.h"
#import "LibraryPortraitViewController.h"
#import "PieChartView.h"

@implementation DeckViewController

@synthesize deck;
@synthesize tableView = _tableView;

- (void)viewDidLoad {
	[super viewDidLoad];

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Card" style:UIBarButtonItemStyleBordered target:self action:@selector(addCard)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backdropBottom.png"]];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.title = @"Deck";
}

- (void)addCard {
    LibraryPortraitViewController * libraryPortraitViewController = [[LibraryPortraitViewController alloc] init];
	libraryPortraitViewController.deck = self.deck;
	libraryPortraitViewController.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:libraryPortraitViewController];
	navController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
	navController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[libraryPortraitViewController release];
	[navController release];	
}
- (void)addedCard {
	NSError *error = nil;
	if (![[self.deck managedObjectContext] save:&error]) {
		NSLog(@"Error! %@", error);
		exit(-1);
	}
	
	[self.tableView reloadData];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)cancel {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (UITableViewCell*)descriptionCellAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"DescriptionCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
    cell.backgroundColor = [UIColor lightGrayColor];
	
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Name";
			cell.detailTextLabel.text = deck.name;
			break;
		case 1:
			cell.textLabel.text = @"Description";
			cell.detailTextLabel.text = deck.text;
			break;
		case 2:
			cell.textLabel.text = nil;
			cell.detailTextLabel.text = nil;
			PieChartView * pieChartView = [[PieChartView alloc] initWithFrame:CGRectMake(20, 0, 240, 240)];
			NSMutableDictionary * dict = [NSMutableDictionary dictionary];
			for (CardItem * cardItem in deck.cards) {
				for (ManaItem * manaItem in cardItem.card.manaItems) {
					NSNumber * total = [dict objectForKey:manaItem.mana.name];
					total = [NSNumber numberWithInt:[total intValue] + [manaItem.quantity intValue]];
					[dict setObject:total forKey:manaItem.mana.name];
				}
			}
			NSLog(@"Dict: %@", dict);
			pieChartView.dataSet = [dict allValues];
			pieChartView.labels = [dict allKeys];
			pieChartView.colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor blueColor], [UIColor grayColor], [UIColor greenColor], [UIColor yellowColor], nil];
			[cell addSubview:pieChartView];
			break;
		default:
			break;
	}
	return cell;
}
- (UITableViewCell*)cardCellAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CardCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
    cell.backgroundColor = [UIColor lightGrayColor];
	
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	CardItem * cardItem = [[deck.cards allObjects] objectAtIndex:indexPath.row];
	cell.textLabel.text = cardItem.card.name;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Quantity: %@", cardItem.quantity];
	return cell;
	
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return [self descriptionCellAtIndexPath:indexPath];
	}
	
    return [self cardCellAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([deck.cards count])	return 2;
	else return 1;
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if ([deck.cards count]) {
			return 3;
		}
		return 2;
	}
	return [deck.cards count];
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return nil;
	return @"Cards";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section > 0) {
		CardItem * cardItem = [[deck.cards allObjects] objectAtIndex:indexPath.row];
		CardViewController *cardViewController = [[CardViewController alloc] init];
		cardViewController.card = cardItem.card;
		[self.navigationController pushViewController:cardViewController animated:YES];
		[cardViewController release];		
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) {
		return 240;
												}												
	return 44;
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


@end
