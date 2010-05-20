//
//  DeckViewController.h
//  UrzasFactory
//
//  Created by Jeremy Lyman on 5/3/10.
//  Copyright 2010 Jeremy Lyman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Deck;

@interface DeckViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	Deck *deck;
	UITableView * _tableView;
}

@property (nonatomic, retain) Deck *deck;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
- (void)cancel;
- (void)addedCard;
@end
