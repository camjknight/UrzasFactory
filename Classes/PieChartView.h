//
//  PieChartView.h
//  Time on Task
//
//  Created by Cameron Knight on 6/17/09.
//  Copyright 2009 Ninth Rock Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieChartView : UIView {
	NSArray *dataSet;
	NSArray *labels;
	NSArray *colors;
	BOOL drawLabels;
}

@property (nonatomic, retain) NSArray *dataSet;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, retain) NSArray *colors;
@property BOOL drawLabels;

- (void) drawChart:(CGRect)rect inContext:(CGContextRef)ctx;

@end
