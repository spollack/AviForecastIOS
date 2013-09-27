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

@property (weak, nonatomic) IBOutlet id <DangerScaleViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;

- (IBAction)donePressed:(id)sender;

@end
