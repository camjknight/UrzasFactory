//
//  UIApplication+TVOut.m
//  MediaMotion2
//
//  Created by Rob Terrell on 5/15/09 
//  Copyright 2009 Stinkbot LLC. All rights reserved.
//
//
//  Modified to support UI orientation and touch
//  indication markers by Kim Ahlberg on 9/16/09.
//  see http://www.theevilboss.com/2009/10/iphone-video-output.html
//
//  To activate orientation handling, add the following to your Application Delegate.
//
//  - (void)application:(UIApplication *)application 
//          didChangeStatusBarOrientation: (UIInterfaceOrientation)oldStatusBarOrientation
//  {
//      [[UIApplication sharedApplication] performSelector:@selector(reformatTVOutOrientation)];	
//  }

 
#define kFPS 10
#define kShowTouchIndicators	YES
 
@interface UIApplication (tvout)
- (void) startTVOut;
- (void) stopTVOut;
- (void) updateTVOut;
- (void) reformatTVOutOrientation;
- (void) registerEvent:(UIEvent*)anEvent;
@end
 
@interface MPTVOutWindow : UIWindow
- (id)initWithVideoView:(id)fp8;
@end
 
@interface MPVideoView : UIView
- (id)initWithFrame:(struct CGRect)fp8;
@end
 
@implementation MPVideoView (tvout)
- (void) addSubview: (UIView *) aView
{	
    [super addSubview:aView];
}
@end

CGImageRef UIGetScreenImage();
 
@interface UIImage (tvout)
+ (UIImage *)imageWithScreenContents;
@end
 
@implementation UIImage (tvout)
+ (UIImage *)imageWithScreenContents
{
    CGImageRef cgScreen = UIGetScreenImage();
    if (cgScreen) {
        UIImage *result = [UIImage imageWithCGImage:cgScreen];
        CGImageRelease(cgScreen);
        return result;
    }
    return nil;
}
@end

@implementation UIWindow (tvout)
// Override the pointInside:withEvent: method of UIWindow to register the touch events.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	// Only register events for touch events.
	if (event.type == UIEventTypeTouches) {
		[[UIApplication sharedApplication] registerEvent:event];
	}
	return YES; // All touches are within the window.
}
@end

UIWindow* deviceWindow;
MPTVOutWindow* tvoutWindow;
NSTimer *updateTimer;
UIImage *image;
UIImageView *mirrorView;
UIEvent *activeEvent;
BOOL done;
 
@implementation UIApplication (tvout)
 
// if you uncomment this, you won't need to call startTVOut in your app.
// but the home button will no longer work! Other badness may follow!
//
// - (void)reportAppLaunchFinished;
//{
//	[self startTVOut];
//}
 
 
- (void) startTVOut;
{
	// you need to have a main window already open when you call start
	if (!tvoutWindow) {
		deviceWindow = [self keyWindow];
 
		MPVideoView *vidView = [[MPVideoView alloc] initWithFrame: CGRectZero];	
		tvoutWindow = [[MPTVOutWindow alloc] initWithVideoView:vidView];
		[tvoutWindow makeKeyAndVisible];
		tvoutWindow.userInteractionEnabled = NO;
 
		mirrorView = [[UIImageView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
 
		[self reformatTVOutOrientation];
		
		mirrorView.center = vidView.center;
		[vidView addSubview: mirrorView];
 
		[deviceWindow makeKeyAndVisible];
 		
		[NSThread detachNewThreadSelector:@selector(updateLoop) toTarget:self withObject:nil];
	}
}

// Adapts the output view to match the current status bar orientation.
- (void) reformatTVOutOrientation;
{
	if(mirrorView)
	{
		if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
			mirrorView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * -1.5);
		} else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
			mirrorView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * 1.5);
		} else { // UIInterfaceOrientationPortrait
			mirrorView.transform = CGAffineTransformIdentity;
		}
	}
}

- (void) stopTVOut;
{
	done = YES;
	if (updateTimer) {
		[updateTimer invalidate];
		[updateTimer release];
		updateTimer = nil;
	}
	if (tvoutWindow) {
		[tvoutWindow release];
		tvoutWindow = nil;
	}
	if (activeEvent) {
		[activeEvent release];
		activeEvent = nil;
	}
}


- (void) registerEvent:(UIEvent*)anEvent {
	// Only register events if we are doing TV out
	// and showing touch indicators.
	if(tvoutWindow && kShowTouchIndicators) {
		@synchronized(activeEvent) {
			if(nil != anEvent && anEvent != activeEvent) {
				[anEvent retain];
				[activeEvent release];
				activeEvent = anEvent;
			}
		}		
	}
}

- (UIImage *)addTouchIndicatorsToImage:(UIImage *)img {
    int w = img.size.width;
    int h = img.size.height; 
	
	static float radius = 15;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
	// Draw the background image.
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 0.5); // Semi transparent blue
	
	// Draw the circle(s)
	UIWindow *window =  [self keyWindow];
	@synchronized(activeEvent)
    {
		int activeTouches = 0;
		for (UITouch *touch in [activeEvent allTouches]) {
			if(touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) {
				continue; // Not an active touch.
			}
			activeTouches++;
			CGPoint point = [touch locationInView:window];
			CGContextFillEllipseInRect(context, CGRectMake((point.x)-radius, (window.frame.size.height - point.y)-radius, radius * 2.0, radius * 2.0));
		}
		
		if (0 == activeTouches) {
			[activeEvent release]; // No active touches, so get rid of the event.
			activeEvent = nil;
		}
	}
	
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	UIImage *returnImage = [UIImage imageWithCGImage:imageMasked];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);	
	CGImageRelease(imageMasked);
	
    return returnImage;
}

- (void) updateTVOut;
{
	mirrorView.image = [self addTouchIndicatorsToImage:[UIImage imageWithScreenContents]];
}

- (void)updateLoop;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    done = NO;
 
    while ( ! done )
    {
		[self performSelectorOnMainThread:@selector(updateTVOut) withObject:nil waitUntilDone:YES];
        [NSThread sleepForTimeInterval: (1.0/kFPS) ];
    }
    [pool release];
}

@end