//
//  PieChartView.m
//  Time on Task
//
//  Created by Cameron Knight on 6/17/09.
//  Copyright 2009 Ninth Rock Games. All rights reserved.
//

#import "PieChartView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PieChartView

@synthesize dataSet,labels,colors,drawLabels;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.opaque = YES;
        // Initialization code
    }
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];

    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	[[UIColor clearColor] set];
	
//    CGContextFillRect(ctx, rect);
	[self drawChart:rect inContext:ctx];
}

//	[self drawChart:CGRectMake(x-150, y-150,300,300) inContext:ctx];
-(void) drawChart:(CGRect)rect inContext:(CGContextRef)ctx
{
	CGContextSetGrayFillColor(ctx, 1.0, 1.0);
	
	CGFloat x = CGRectGetWidth(rect)/2;
	CGFloat y = CGRectGetHeight(rect)/2;

	double radius = CGRectGetHeight(rect)/2-16;
	
	CGContextSetAllowsAntialiasing(ctx, YES);

	CGContextSaveGState(ctx);
	CGSize offset = {0,-6};
	CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0f] CGColor]);
	CGContextSetShadowWithColor(ctx, offset, 10.0, [[UIColor colorWithRed:0 green:0 blue:0 alpha:.75f] CGColor]);
	//	CGContextTranslateCTM(ctx, 1, 1);
    CGContextMoveToPoint(ctx, x, y);     
    CGContextAddArc(ctx, x, y, radius+2,  0, M_PI*2, 0); 
	CGContextClosePath(ctx); 
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1.0);
	CGContextSetLineWidth(ctx, 0.0);	
	// need some values to draw pie charts
	
	float total = 0;
//	NSLog(@"COUNT %d",[dataSet count]);
	for (NSNumber * number in dataSet) {
//		NSLog(@"NUMBER %@",number);
		total += [number floatValue];
	}
//	NSLog(@"TOTAL %d", total);
	float current_angle = 0.0;
	for (int i = 0; i < [dataSet count]; ++i) {
		
		float fraction = [[dataSet objectAtIndex:i] floatValue] / total;
//		NSLog(@"FRACTION %f",fraction);
		double startAngle = current_angle * M_PI * 2;
		double endAngle = (current_angle + fraction) * M_PI * 2;
		current_angle += fraction;
		
		CGContextSetFillColorWithColor(ctx, [[colors objectAtIndex:i] CGColor]);
		CGContextBeginPath(ctx);
		CGContextMoveToPoint(ctx, x, y);
		CGContextAddArc(ctx, x, y, radius,  (startAngle - M_PI/2), (endAngle - M_PI/2), NO); 
		CGContextAddLineToPoint(ctx, x, y);
		CGContextClosePath(ctx);

		if(fabs(startAngle - endAngle) > 0.001)
		{
			CGContextDrawPath(ctx,kCGPathFillStroke);			
			if (drawLabels && fraction != 0.0) {
				float angle = (startAngle + endAngle)/2;
				// normalize the angle
				float normalisedAngle = angle;
				if (normalisedAngle > M_PI * 2)
					normalisedAngle = normalisedAngle - M_PI * 2;
				else if (normalisedAngle < 0)
					normalisedAngle = normalisedAngle + M_PI * 2;
				
				int labelx = x + sin(normalisedAngle) * (radius/2);
				int labely = y - cos(normalisedAngle) * (radius/2);
				
				if(fraction == 1.0) {
					labelx = x + sin(normalisedAngle);
					labely = y - cos(normalisedAngle);
				}
				
				CGContextSaveGState(ctx);
				offset.width = 0;
				offset.height=-1;
				CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f] CGColor]);
				CGContextSetShadowWithColor(ctx, offset, 3.0, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] CGColor]);
				
				
				[[UIColor whiteColor] set];
//				CGAffineTransform xform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
//				CGContextSetTextMatrix(ctx, xform);
				
				NSString *caption = [NSString stringWithFormat:@"%@\n%0.0f%%",[labels objectAtIndex:i], fraction*100.0];
				CGSize size = [caption sizeWithFont:[UIFont boldSystemFontOfSize:14.0] forWidth:radius lineBreakMode:UILineBreakModeWordWrap];
				[caption drawInRect:CGRectMake(labelx-(radius/2.0), labely-size.height, radius,size.height*2) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
				
				CGContextRestoreGState(ctx);
			}
		}
		
	}
	

}

/*
 
- (void)drawPDFInContext:(CGContextRef)ctx {	
//	int onTask = timeOnTaskObservation.totalOnTask;
//	int offTask = timeOnTaskObservation.totalOffTask;
	UIGraphicsPushContext(ctx);
	
	CGRect rect = self.frame;
	srand(time(0));
	CGContextSetGrayFillColor(ctx, 1.0, 1.0);
    CGContextFillRect(ctx, rect);
	
	
	CGFloat x = CGRectGetWidth(rect)/2;
	CGFloat y = 187;
	double radius = 105;
//	[self drawChart:CGRectMake(x, y,300,300) inContext:ctx];
	CGContextSetAllowsAntialiasing(ctx, YES);
	
	UILabel *label = [[UILabel alloc] initWithFrame:rect];
	//	label.opaque = NO;
	//	label.backgroundColor = [UIColor clearColor];
	// define stroke color
	CGContextSaveGState(ctx);
	CGSize offset = {6,-6};
	CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0f] CGColor]);
	CGContextSetShadowWithColor(ctx, offset, 10.0, [[UIColor colorWithRed:0 green:0 blue:0 alpha:.75f] CGColor]);
	//	CGContextTranslateCTM(ctx, 1, 1);
    CGContextMoveToPoint(ctx, x, y);     
    CGContextAddArc(ctx, x, y, radius,  0, M_PI*2, 0); 
	CGContextClosePath(ctx); 
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	
	
	
	label.bounds=CGRectMake(36, 36,300,24);
	label.adjustsFontSizeToFitWidth = YES;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:18];
	label.text = [classroom description];
	label.textAlignment = UITextAlignmentLeft;
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
//	[label.layer drawInContext:ctx];
	//	[label drawRect:label.bounds];
	
	label.bounds=CGRectMake(37, 56,300,19);
	label.adjustsFontSizeToFitWidth = YES;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:14];
	label.text = [classroom detailDescription];
	label.textAlignment = UITextAlignmentLeft;
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
//	[label.layer drawInContext:ctx];
	label.bounds=CGRectMake(CGRectGetWidth(rect)-336, 36,300,19);
	label.adjustsFontSizeToFitWidth = YES;
	label.textColor = [UIColor blackColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:12];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM d, yyyy 'at' h:mm a"];
	label.text =  [dateFormatter stringFromDate:[timeOnTaskObservation date]];
	[dateFormatter release];
	label.textAlignment = UITextAlignmentRight;
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
//	[label.layer drawInContext:ctx];	
	
	
	CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1.0);
	CGContextSetLineWidth(ctx, 0.0);	
	// need some values to draw pie charts
	
	double current_angle = 0.0;
	double fraction = (float)timeOnTaskObservation.totalOnTask/(float)(timeOnTaskObservation.totalOnTask+timeOnTaskObservation.totalOffTask);
	double fraction2 = (float)timeOnTaskObservation.totalOffTask/(float)(timeOnTaskObservation.totalOnTask+timeOnTaskObservation.totalOffTask);
	
	
	double pie1_start = current_angle*M_PI *2;	
	double pie1_finish = (current_angle + fraction) * M_PI * 2;
	current_angle = fraction;
	double pie2_start = current_angle*M_PI *2;	
	double pie2_finish = (current_angle + fraction2) * M_PI * 2;
	
	CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:100.0/255.0 green:149.0/255.0 blue:237.0/255.0 alpha:1] CGColor]);
    CGContextMoveToPoint(ctx, x, y);     
    CGContextAddArc(ctx, x, y, radius,  (pie1_start - M_PI/2), (pie1_finish - M_PI/2), 1); 
	CGContextAddLineToPoint(ctx, x, y);
	CGContextClosePath(ctx); 
	CGContextDrawPath(ctx,kCGPathFillStroke);
	
    CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0.0/255.0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
    CGContextMoveToPoint(ctx, x, y);     
    CGContextAddArc(ctx, x, y, radius,  (pie2_start - M_PI/2), (pie2_finish - M_PI/2), 1); 
	CGContextAddLineToPoint(ctx, x, y);
	CGContextClosePath(ctx); 
	CGContextDrawPath(ctx,kCGPathFillStroke);
	
	float angle = (pie1_start + pie1_finish)/2;
	// normalize the angle
	float normalisedAngle = angle;
	if (normalisedAngle > M_PI * 2)
		normalisedAngle = normalisedAngle - M_PI * 2;
	else if (normalisedAngle < 0)
		normalisedAngle = normalisedAngle + M_PI * 2;
	
	int labelx = x + sin(normalisedAngle) * (radius/2);
	int labely = y - cos(normalisedAngle) * (radius/2);
	
	CGContextSaveGState(ctx);
	offset.width = 0;
	offset.height=-1;
	CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f] CGColor]);
	CGContextSetShadowWithColor(ctx, offset, 3.0, [[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor]);
	
	//	NSLog(@"%f %f %f %f",labelx-radius/2, labely-radius/2, radius, radius);
	label.bounds=CGRectMake(labelx-radius/2, labely-radius/2, radius, radius);
	label.adjustsFontSizeToFitWidth = YES;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14];
	//	label.text = @"On Task\n43%";
	label.text = [NSString stringWithFormat:@"On Task\n%0.0f%%",fraction*100];
	label.textAlignment = UITextAlignmentCenter;
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
	[label.layer drawInContext:ctx];
	
//	NSString *caption = [NSString stringWithFormat:NSLocalizedString(@"On Task\n%0.0f%%",nil), 66.66];
//	[caption drawInRect:CGRectMake(10, 10, 300,60) withFont:[UIFont boldSystemFontOfSize:14.0] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];

	angle = (pie2_start + pie2_finish)/2;
	// normalize the angle
	normalisedAngle = angle;
	if (normalisedAngle > M_PI * 2)
		normalisedAngle = normalisedAngle - M_PI * 2;
	else if (normalisedAngle < 0)
		normalisedAngle = normalisedAngle + M_PI * 2;
	
	labelx = x + sin(normalisedAngle) * (radius/2);
	labely = y - cos(normalisedAngle) * (radius/2);
	
	//	UILabel *label = [[UILabel alloc] initWithFrame:rect];
	//	NSLog(@"%f %f %f %f",labelx-radius/2, labely-radius/2, radius, radius);
	label.bounds=CGRectMake(labelx-radius/2, labely-radius/2, radius, radius);
	label.adjustsFontSizeToFitWidth = YES;
	label.textColor = [UIColor whiteColor];
	//	label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	//	label.shadowOffset = CGSizeMake(0,1);
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14];
	label.text = [NSString stringWithFormat:@"Off Task\n%0.0f%%",fraction2*100];
	label.textAlignment = UITextAlignmentCenter;
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
//	[label.layer drawInContext:ctx];
	CGContextRestoreGState(ctx);
	
	int base = 325;

	//	label.textColor = [UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1];
	label.textColor = [UIColor colorWithRed:8.0/255.0 green:37.0/255.0 blue:103.0/255.0 alpha:1];
	//	label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	//	label.shadowOffset = CGSizeMake(0,1);
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14];
	label.textAlignment = UITextAlignmentCenter;
	label.lineBreakMode = UILineBreakModeWordWrap; 
	label.numberOfLines = 0;
	label.bounds=CGRectMake(54, base, 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = @"Student #";
//	[label.layer drawInContext:ctx];
	
	label.bounds=CGRectMake(180, base, 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = @"Off Task";
//	[label.layer drawInContext:ctx];
	
	label.bounds=CGRectMake(306, base, 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = @"On Task";
//	[label.layer drawInContext:ctx];
	
	label.bounds=CGRectMake(432, base, 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = @"Percent";
//	[label.layer drawInContext:ctx];

	CGContextBeginPath (ctx); 
	CGContextMoveToPoint (ctx, 54, base+25); 
	CGContextAddLineToPoint (ctx, 558, base+25); 
	CGContextClosePath (ctx);
	CGContextSetLineWidth(ctx, 1.0);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
	CGContextDrawPath (ctx, kCGPathStroke);
	
		
	int i;
	int count = [timeOnTaskRecords count];
//	int base = 350;
	int root = base;
	int height = base;
	BOOL first = YES;
	for(i = 1; i <= count; i++)
	{
		TimeOnTaskRecord *record = [timeOnTaskRecords objectAtIndex:(i-1)];
		label.backgroundColor = [UIColor whiteColor];
		
		label.bounds=CGRectMake(54, base+(25*i), 126, 26);
		label.adjustsFontSizeToFitWidth = YES;
		label.text = [NSString stringWithFormat:@"%d",i];
		label.font = [UIFont boldSystemFontOfSize:14];
//		[label.layer drawInContext:ctx];
		if(!(i%2))		label.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:1 alpha:1];
		label.bounds=CGRectMake(180, base+(25*i), 126, 26);
		label.adjustsFontSizeToFitWidth = YES;
		label.font = [UIFont systemFontOfSize:14];
		label.text = [NSString stringWithFormat:@"%d",record.offTask];
//		[label.layer drawInContext:ctx];
		
		label.bounds=CGRectMake(306, base+(25*i), 126, 26);
		label.adjustsFontSizeToFitWidth = YES;
		label.text = [NSString stringWithFormat:@"%d",record.onTask];
//		[label.layer drawInContext:ctx];
		
		label.bounds=CGRectMake(432, base+(25*i), 126, 26);
		label.adjustsFontSizeToFitWidth = YES;
		if((record.onTask + record.offTask) == 0)
			label.text = @"N/A";
		else
			label.text = [NSString stringWithFormat:@"%.2f%%",(float)record.onTask/(float)(record.onTask + record.offTask)*100.0];
//		[label.layer drawInContext:ctx];
		if(!first)
		{
			CGContextBeginPath (ctx); 
			CGContextMoveToPoint (ctx, 180, base+(25*i)); 
			CGContextAddLineToPoint (ctx, 558, base+(25*i)); 
			CGContextClosePath (ctx);
			CGContextSetLineWidth(ctx, 1.0);
			CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:100.0/255.0 green:149.0/255.0 blue:237.0/255.0 alpha:1] CGColor]);
			//		CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:0/255.0 blue:0/255.0 alpha:1] CGColor]);
			CGContextDrawPath (ctx, kCGPathStroke);
		}
		else first = NO;
		height = base+(25*i);
		if(height >= 700 && i < count)
		{
			label.textColor = [UIColor colorWithRed:8.0/255.0 green:37.0/255.0 blue:103.0/255.0 alpha:1];
			//	label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
			//	label.shadowOffset = CGSizeMake(0,1);
			label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont boldSystemFontOfSize:14];
			label.textAlignment = UITextAlignmentCenter;
			label.lineBreakMode = UILineBreakModeWordWrap; 
			label.numberOfLines = 0;
			
			CGContextBeginPath (ctx); 
			CGContextMoveToPoint (ctx, 180, root+25); 
			CGContextAddLineToPoint (ctx, 180, base+(25*(i+1))); 
			CGContextClosePath (ctx);
			CGContextSetLineWidth(ctx, 1.0);
			CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
			CGContextDrawPath (ctx, kCGPathStroke);
			
			CGContextSetLineWidth(ctx, 3.0);
			CGContextBeginPath (ctx); 
			CGContextMoveToPoint (ctx, 54, base+(25*(i+1))); 
			CGContextAddLineToPoint (ctx, 558, base+(25*(i+1))); 
			//	CGContextAddLineToPoint (ctx, 558, 675+3); 
			//	CGContextAddLineToPoint (ctx, 54, 675+3); 
			//	CGContextAddLineToPoint (ctx, 54, 675);
			CGContextClosePath (ctx);
			CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
			//	CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
			//	CGContextDrawPath (ctx, kCGPathFillStroke);
			CGContextDrawPath (ctx, kCGPathStroke);
			
			CGContextSaveGState(ctx);
			CGContextEndPage(ctx);
			CGContextBeginPage(ctx, &rect);
			CGContextRestoreGState(ctx);
			label.bounds=CGRectMake(54, 62, 126, 26);
			label.adjustsFontSizeToFitWidth = YES;
			label.text = @"Student #";
//			[label.layer drawInContext:ctx];
			
			label.bounds=CGRectMake(180, 62, 126, 26);
			label.adjustsFontSizeToFitWidth = YES;
			label.text = @"Off Task";
//			[label.layer drawInContext:ctx];
			
			label.bounds=CGRectMake(306, 62, 126, 26);
			label.adjustsFontSizeToFitWidth = YES;
			label.text = @"On Task";
//			[label.layer drawInContext:ctx];
			
			label.bounds=CGRectMake(432, 62, 126, 26);
			label.adjustsFontSizeToFitWidth = YES;
			label.text = @"Percent";
//			[label.layer drawInContext:ctx];
			
			CGContextBeginPath (ctx); 
			CGContextMoveToPoint (ctx, 54, 62+25); 
			CGContextAddLineToPoint (ctx, 558, 62+25); 
			CGContextClosePath (ctx);
			CGContextSetLineWidth(ctx, 1.0);
			CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
			CGContextDrawPath (ctx, kCGPathStroke);
			
			base = 62 -25*(i);
			root = 62;
			first = YES;
		}
//		NSLog(@"Base: %d",base);
	}
//	CGContextBeginPath (ctx); 
//	CGContextMoveToPoint (ctx, 180, base+25); 
//	CGContextAddLineToPoint (ctx, 180, base+(25*(i))); 
//	CGContextClosePath (ctx);
//	CGContextSetLineWidth(ctx, 1.0);
//	CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
//	CGContextDrawPath (ctx, kCGPathStroke);
	
	CGContextBeginPath (ctx); 
	CGContextMoveToPoint (ctx, 180, root+25); 
	CGContextAddLineToPoint (ctx, 180, base+(25*(i))); 
	CGContextClosePath (ctx);
	CGContextSetLineWidth(ctx, 1.0);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
	CGContextDrawPath (ctx, kCGPathStroke);
	
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14];
	CGContextSetLineWidth(ctx, 3.0);
	CGContextBeginPath (ctx); 
	CGContextMoveToPoint (ctx, 54, base+(25*(i))); 
	CGContextAddLineToPoint (ctx, 558, base+(25*(i))); 
	//	CGContextAddLineToPoint (ctx, 558, 675+3); 
	//	CGContextAddLineToPoint (ctx, 54, 675+3); 
	//	CGContextAddLineToPoint (ctx, 54, 675);
	CGContextClosePath (ctx);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
	//	CGContextSetFillColorWithColor(ctx, [[UIColor colorWithRed:0 green:71.0/255.0 blue:171.0/255.0 alpha:1] CGColor]);
	//	CGContextDrawPath (ctx, kCGPathFillStroke);
	CGContextDrawPath (ctx, kCGPathStroke);
	
	label.bounds=CGRectMake(54, base+(25*(i)), 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = @"TOTAL";
//	[label.layer drawInContext:ctx];
	
	label.bounds=CGRectMake(180, base+(25*(i)), 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = [NSString stringWithFormat:@"%d",timeOnTaskObservation.totalOffTask];
//	[label.layer drawInContext:ctx];
	
	label.bounds=CGRectMake(306, base+(25*(i)), 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	label.text = [NSString stringWithFormat:@"%d",timeOnTaskObservation.totalOnTask];
//	[label.layer drawInContext:ctx];
	
	label.bounds=CGRectMake(432, base+(25*(i)), 126, 26);
	label.adjustsFontSizeToFitWidth = YES;
	if((timeOnTaskObservation.totalOnTask+timeOnTaskObservation.totalOffTask) == 0)
		label.text = @"N/A";
	else
		
	label.text = [NSString stringWithFormat:@"%.2f%%",(float)timeOnTaskObservation.totalOnTask/(float)(timeOnTaskObservation.totalOnTask+timeOnTaskObservation.totalOffTask)*100.0];
//	[label.layer drawInContext:ctx];
	
	
	[label release];
	
	//	UILabel *onTask = [[UILabel alloc] init];
	//	onTask.text = @"On Task";
	//	[onTask drawTextInRect:CGRectMake(labelx-radius/2, labely-radius/2, radius, radius)];
	
	 
//	 CGContextSelectFont (ctx, "Helvetica-Bold", 14, kCGEncodingMacRoman);
//	 CGContextSetTextDrawingMode (ctx, kCGTextFill);
//	 CGContextSetRGBFillColor (ctx, 0, 0, 0, 1);
//	 const char *text4 = "On Task";
//	 CGContextShowTextAtPoint (ctx, labelx, labely, text4, strlen(text4));
//	 
//	 
//	 angle = (pie2_start + pie2_finish)/2;
//	 // normalize the angle
//	 normalisedAngle = angle;
//	 if (normalisedAngle > M_PI * 2)
//	 normalisedAngle = normalisedAngle - M_PI * 2;
//	 else if (normalisedAngle < 0)
//	 normalisedAngle = normalisedAngle + M_PI * 2;
//	 
//	 labelx = x + sin(normalisedAngle) * (radius/2);
//	 labely = y + cos(normalisedAngle) * (radius/2);
//	 
//	 CGContextSelectFont (ctx, "Helvetica-Bold", 14, kCGEncodingMacRoman);
//	 CGContextSetTextDrawingMode (ctx, kCGTextFill);
//	 CGContextSetRGBFillColor (ctx, 0, 0, 0, 1);
//	 const char *text5 = "Off Task";
//	 CGContextShowTextAtPoint (ctx, labelx, labely, text5, strlen(text5));
		UIGraphicsPopContext();
	
}
*/
- (void)dealloc {
    [super dealloc];
}


@end
