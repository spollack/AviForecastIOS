//
//  DetailsViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailsViewController.h"

@implementation DetailsViewController

@synthesize URL = _URL;
@synthesize delegate = _delegate;
@synthesize webView = _webView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"DetailsViewController viewDidLoad called");
    
    if (self.URL) {
        
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:self.URL];
        [self.webView loadRequest:request];
    }

}

- (void)viewDidUnload
{
    [self setDelegate:nil];
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)donePressed:(id)sender
{
    [self.delegate detailsViewControllerDidFinish:self];
}
@end
