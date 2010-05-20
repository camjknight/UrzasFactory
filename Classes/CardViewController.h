//
//  CardViewController.h
//  UrzasFactory
//
//  Created by Cameron Knight on 4/28/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UFTableViewController.h"

@class Card;
@class Deck;
@interface CardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView * _tableView;
	Card * card;
	Deck * deck;
	NSMutableDictionary * fields;
	id delegate;
}
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) Card * card;
@property (nonatomic, retain) NSMutableDictionary * fields;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) Deck * deck;
@end
