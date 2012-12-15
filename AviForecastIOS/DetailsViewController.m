//
//  DetailsViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//

#import "DetailsViewController.h"
#import "AFNetworkActivityIndicatorManager.h"


@implementation DetailsViewController

@synthesize URL = _URL;
@synthesize delegate = _delegate;
@synthesize webView = _webView;

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (IBAction)donePressed:(id)sender
{
    // cancel any loading that may be in progress
    [self.webView stopLoading];
    
    // tell our delegate that we are done
    [self.delegate detailsViewControllerDidFinish:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.URL) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:self.URL];
        [self.webView loadRequest:request];
    }
}

- (void)viewDidUnload
{
    [self setDelegate:nil];
    [self.webView setDelegate:nil];
    [self setWebView:nil];
    [self setURL:nil];
    
    [super viewDidUnload];
}

// for iOS6+
- (BOOL)shouldAutorotate
{
    return YES;
}

// for iOS6+
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

// for iOS5 and earlier
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // we allow this view to be flipped to either landscape, plus portrait
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
