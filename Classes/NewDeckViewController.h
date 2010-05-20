//
//  NewDeckViewController.h
//  UrzasFactory
//
//  Created by Cameron Knight on 5/12/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NewDeckViewControllerDelegate;
@class Deck;

@interface NewDeckViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	id <NewDeckViewControllerDelegate> delegate;
	Deck * deck;
	UITextView * textView;
	UITextField * textField;
	UIImageView * imageView;
	UITableViewCell * textFieldCell;
	UITableViewCell * textViewCell;
	UITableView * _tableView;
}
@property (nonatomic, assign) id <NewDeckViewControllerDelegate> delegate;
@property (nonatomic, retain) Deck * deck;
@property (nonatomic, retain) IBOutlet UITextView * textView;
@property (nonatomic, retain) IBOutlet UITextField * textField;
@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UITableViewCell * textFieldCell;
@property (nonatomic, retain) IBOutlet UITableViewCell * textViewCell;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


@protocol NewDeckViewControllerDelegate
- (void)newDeckViewController:(NewDeckViewController *)controller didFinishWithSave:(BOOL)save;
@end

