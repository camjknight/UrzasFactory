//
//  DecksViewController.h
//  UrzasFactory
//
//  Created by Cameron Knight on 2/25/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFTableViewController.h"
#import "NewDeckViewController.h"

@interface DecksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, NewDeckViewControllerDelegate> {
	UITableView * _tableView;
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *_newManagedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *newManagedObjectContext;
@property (nonatomic, retain) IBOutlet UITableView * tableView;

@end
