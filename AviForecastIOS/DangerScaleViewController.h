//
//  DangerScaleViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 2/7/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//


@class DangerScaleViewController;

@protocol DangerScaleViewControllerDelegate
- (void) dangerScaleViewControllerDidFinish: (DangerScaleViewController *) controller;
@end

@interface DangerScaleViewController : UIViewController <UIScrollViewDelegate>

// NOTE if we drop iOS4.x support, change "unsafe_unretained" to "weak"

@property (unsafe_unretained, nonatomic) IBOutlet id <DangerScaleViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView * scrollView;

- (IBAction)donePressed:(id)sender;

@end
