//
//  ViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize forecastEngine = _forecastEngine;
@synthesize levelDisplay = _levelDisplay;
@synthesize map = _map;

- (void) mapView:(MKMapView *) mapView
    didUpdateUserLocation:(MKUserLocation *) userLocation
{
    // center and zoom in on the user's location
    
    CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;

    // 200km x 200km
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 200000, 200000); 
    
    [mapView setRegion:region animated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    
    self.forecastEngine = [[ForecastEngine alloc] init];
    
    [self.forecastEngine forecastForRegionId:@"6" 
        onCompletion:^(int aviLevel)
        {
            self.levelDisplay.text = [NSString stringWithFormat: @"%d", aviLevel];
        }];   

}

- (void)viewDidUnload
{
    [self setLevelDisplay:nil];
    [self setMap:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
