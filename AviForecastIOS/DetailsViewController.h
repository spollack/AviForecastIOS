//
//  DetailsViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class DetailsViewController;

@protocol DetailsViewControllerDelegate
- (void) detailsViewControllerDidFinish: (DetailsViewController *) controller;
@end

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) NSURL * URL; 
@property (weak, nonatomic) IBOutlet id <DetailsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIWebView * webView;

- (IBAction)donePressed:(id)sender;

@end
