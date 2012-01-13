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
@synthesize map = _map;
@synthesize haveUpdatedUserLocation = _haveUpdatedUserLocation;
@synthesize fillColor = _fillColor;

- (id) init
{
    self = [super init];
    
    if (self) {
        self.haveUpdatedUserLocation = FALSE; 
    }
        
    return self;
}

- (void) mapView:(MKMapView *) mapView
    didUpdateUserLocation:(MKUserLocation *) userLocation
{
    // once we have the user's location, center and zoom in
    // BUGBUG what if we never get the user's location? 
    
    if (!self.haveUpdatedUserLocation) {
        NSLog(@"updating map position based on user location");
        
        CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;
        
        // 200km x 200km
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 200000, 200000); 
        
        [mapView setRegion:region animated:TRUE];

        self.haveUpdatedUserLocation = TRUE; 
    }
}

- (MKOverlayView *) mapView:
    (MKMapView *) mapView 
    viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolygonView * view = nil;
    
    NSLog(@"viewForOverlay called");
    
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        view = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *) overlay]; 
        view.fillColor = self.fillColor;
        view.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        view.lineWidth = 2;
    }
        
    return view;
}

- (UIColor *) colorForAviLevel:(int) aviLevel
{
    UIColor * color = nil;
    
    switch (aviLevel) {
        case AVI_LEVEL_LOW: 
            color = [UIColor colorWithRed:(80/255.0) green:(184/255.0) blue:(72/255.0) alpha:0.6];
            break;
        case AVI_LEVEL_MODERATE: 
            color = [UIColor colorWithRed:(255/255.0) green:(242/255.0) blue:(0/255.0) alpha:0.6];
            break;
        case AVI_LEVEL_CONSIDERABLE: 
            color = [UIColor colorWithRed:(247/255.0) green:(148/255.0) blue:(30/255.0) alpha:0.6];
            break;
        case AVI_LEVEL_HIGH: 
            color = [UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:0.6];
            break;
        case AVI_LEVEL_EXTREME: 
            color = [UIColor colorWithRed:(35/255.0) green:(31/255.0) blue:(32/255.0) alpha:0.6];
            break;
        default:
            color = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:0.6];
            break;
    }
    
    return color;
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
            self.fillColor = [self colorForAviLevel:aviLevel];
            
            
            // BUGBUG temp to test overlays
            MKMapPoint p1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47, -122));
            MKMapPoint p2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48, -122));
            MKMapPoint p3 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(48, -123));
            MKMapPoint pts[3] = {p1,p2,p3};
            MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:3];
            [self.map addOverlay:polygon];
            
        }];   

}

- (void)viewDidUnload
{
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
