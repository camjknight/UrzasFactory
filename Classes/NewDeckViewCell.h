//
//  NewDeckViewCell.h
//  UrzasFactory
//
//  Created by Cameron Knight on 5/12/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewDeckViewCell : UITableViewCell {
	IBOutlet UILabel * textLabel;
	IBOutlet UITextField * textField;
}

@property (nonatomic, retain) UILabel * textLabel;
@property (nonatomic, retain) UITextField * textField;

@end
