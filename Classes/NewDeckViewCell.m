//
//  NewDeckViewCell.m
//  UrzasFactory
//
//  Created by Cameron Knight on 5/12/10.
//  Copyright 2010 Moblico. All rights reserved.
//

#import "NewDeckViewCell.h"


@implementation NewDeckViewCell

@synthesize textLabel, textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
