//
//  DangerScaleViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 2/7/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//

#import "DangerScaleViewController.h"

@implementation DangerScaleViewController

@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self.scrollView.subviews objectAtIndex:0];
}

- (IBAction)donePressed:(id)sender
{
    // tell our delegate that we are done
    [self.delegate dangerScaleViewControllerDidFinish:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the content size of the scroll view based on the image size
    CGSize imageSize = ((UIImageView *)[self.scrollView.subviews objectAtIndex:0]).image.size;
    self.scrollView.contentSize = imageSize;
}

- (void)viewDidUnload
{
    [self setDelegate:nil];
    [self.scrollView setDelegate:nil];
    [self setScrollView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // this view only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
