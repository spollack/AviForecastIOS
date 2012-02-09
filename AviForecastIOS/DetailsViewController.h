//
//  DetailsViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//

//
// provides a modal detailed forecast view
//


@class DetailsViewController;

@protocol DetailsViewControllerDelegate
- (void) detailsViewControllerDidFinish: (DetailsViewController *) controller;
@end

@interface DetailsViewController : UIViewController <UIWebViewDelegate>

// NOTE if we drop iOS4.x support, change "unsafe_unretained" to "weak"

@property (strong, nonatomic) NSURL * URL; 
@property (unsafe_unretained, nonatomic) IBOutlet id <DetailsViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView * webView;

- (IBAction)donePressed:(id)sender;

@end
