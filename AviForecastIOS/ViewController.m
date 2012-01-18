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
@synthesize overlay = _overlay;

- (id) init
{
    self = [super init];
    
    if (self) {
        self.haveUpdatedUserLocation = FALSE; 
    }
        
    return self;
}

- (UIColor *) colorForAviLevel:(int) aviLevel
{
    UIColor * color = nil;
    
    switch (aviLevel) {
        case AVI_LEVEL_LOW: 
            color = [UIColor colorWithRed:(80/255.0) green:(184/255.0) blue:(72/255.0) alpha:0.7];
            break;
        case AVI_LEVEL_MODERATE: 
            color = [UIColor colorWithRed:(255/255.0) green:(242/255.0) blue:(0/255.0) alpha:0.7];
            break;
        case AVI_LEVEL_CONSIDERABLE: 
            color = [UIColor colorWithRed:(247/255.0) green:(148/255.0) blue:(30/255.0) alpha:0.7];
            break;
        case AVI_LEVEL_HIGH: 
            color = [UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:0.7];
            break;
        case AVI_LEVEL_EXTREME: 
            color = [UIColor colorWithRed:(35/255.0) green:(31/255.0) blue:(32/255.0) alpha:0.7];
            break;
        default:
            color = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:0.7];
            break;
    }
    
    return color;
}

- (void) mapView:(MKMapView *) mapView
    didUpdateUserLocation:(MKUserLocation *) userLocation
{
    NSLog(@"didUpdateUserLocation called");

    // once we have the user's actual location, center and zoom in; however, only do this once, 
    // so the map doesn't keep jumping around
    
    if (!self.haveUpdatedUserLocation) {
        
        CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;
        
        if (location.latitude < 0.1 && location.longitude < 0.1) {
            NSLog(@"location is near (0,0), not updating");
        } else {
            NSLog(@"updating map position based on user location");

            // default to a 200km x 200km view
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 200000, 200000); 
            [mapView setRegion:region animated:TRUE];

            self.haveUpdatedUserLocation = TRUE; 
        }
    }
}

- (MKOverlayView *) mapView:
    (MKMapView *) mapView 
    viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"viewForOverlay called");

    MKPolygonView * view = nil;

    if ([overlay isKindOfClass:[MKPolygon class]]) {
        view = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *) overlay]; 
        view.fillColor = [self colorForAviLevel:AVI_LEVEL_UNKNOWN];
        view.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        view.lineWidth = 2;
        
        self.overlay = view; 
    }
        
    return view;
}

- (void) updateData: (id)notification {
    NSLog(@"updateData called");
    
    if (self.forecastEngine) {
        [self.forecastEngine forecastForRegionId:@"6" 
            onCompletion:^(int aviLevel)
            {
                if (self.overlay) {
                    // set the overlay color
                    self.overlay.fillColor = [self colorForAviLevel:aviLevel];
                    
                    // redraw the annotation
                    [self.overlay setNeedsDisplay];                     
                }
            }];
    }
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
    
    
    NSLog(@"viewDidLoad called");
   
    // BUGBUG temp
    MKMapPoint p1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.476, -121.722));
    MKMapPoint p2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.391, -121.476));
    MKMapPoint p3 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.709, -121.130));
    MKMapPoint p4 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.861, -121.795));
    MKMapPoint pts[4] = {p1,p2,p3,p4};
    MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:4];
    [self.map addOverlay:polygon];

    
    self.forecastEngine = [[ForecastEngine alloc] init];
    
    // fetch the data
    [self updateData:nil];
    
    // receive activation notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
