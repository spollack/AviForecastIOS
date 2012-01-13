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
    // once we have the user's location, center and zoom in
    // BUGBUG what if we never get the user's location? 
    // BUGBUG only do this once...
    
    NSLog(@"didUpdateUserLocation called");

    CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;

    // 200km x 200km
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 200000, 200000); 
    
    [mapView setRegion:region animated:TRUE];
}

- (MKOverlayView *) mapView:
    (MKMapView *) mapView 
    viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolygonView * view = nil;
    
    NSLog(@"viewForOverlay called");
    
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        view = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *) overlay]; 
        view.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
        view.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        view.lineWidth = 2;
    }
    
    return view;
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
    
    // BUGBUG temp to test networking
    [self.forecastEngine forecastForRegionId:@"6" 
        onCompletion:^(int aviLevel)
        {
            self.levelDisplay.text = [NSString stringWithFormat: @"%d", aviLevel];
        }];   

    
    // BUGBUG temp to test overlays
    MKMapPoint p1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47, -122));
    MKMapPoint p2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48, -122));
    MKMapPoint p3 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48, -123));
    MKMapPoint pts[3] = {p1,p2,p3};
    MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:3];
    [self.map addOverlay:polygon];
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
