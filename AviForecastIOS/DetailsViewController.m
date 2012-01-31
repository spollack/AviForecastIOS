//
//  DetailsViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIApplication+NetworkActivity.h"


@implementation DetailsViewController

@synthesize URL = _URL;
@synthesize delegate = _delegate;
@synthesize webView = _webView;

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] toggleNetworkActivityIndicatorVisible:TRUE];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] toggleNetworkActivityIndicatorVisible:FALSE];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] toggleNetworkActivityIndicatorVisible:FALSE];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // we allow this view to be flipped to either landscape
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)donePressed:(id)sender
{
    // cancel any loading that may be in progress
    [self.webView stopLoading];
    
    // tell our delegate that we are done
    [self.delegate detailsViewControllerDidFinish:self];
}

@end
