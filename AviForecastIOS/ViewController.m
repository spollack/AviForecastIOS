//
//  ViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ForecastEngine.h"
#import "RegionData.h"

@implementation ViewController

@synthesize map = _map;
@synthesize todayButton = _todayButton;
@synthesize tomorrowButton = _tomorrowButton;
@synthesize forecastEngine = _forecastEngine;
@synthesize regionsDict = _regionsDict;
@synthesize haveUpdatedUserLocation = _haveUpdatedUserLocation;
@synthesize mode = _mode; 

- (id) init
{
    self = [super init];
    
    if (self) {
        self.haveUpdatedUserLocation = FALSE; 
        self.mode = MODE_TODAY;
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

    MKPolygonView * overlayView = nil;

    if ([overlay isKindOfClass:[RegionData class]]) {
        RegionData * regionData = (RegionData *)overlay; 
        overlayView = [[MKPolygonView alloc] initWithPolygon:regionData.polygon]; 
        overlayView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        overlayView.lineWidth = 2;

        // set the overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];                        
        overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // stash the view so we can update it later if the data changes
        regionData.overlayView = overlayView; 
    }
        
    return overlayView;
}

- (void) recalcAnnotation:(RegionData *) regionData
{
    if (regionData.overlayView) {
        // look up and set the aviLevel-based overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];
        regionData.overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // redraw the annotation
        [regionData.overlayView setNeedsDisplay];
    }
}

- (void) recalcAnnotations
{
    NSArray * allValues = [self.regionsDict allValues];
    for (id object in allValues) {
        RegionData * regionData = (RegionData *)object;
        [self recalcAnnotation: regionData];
    }
}

- (void) updateData: (id) notification {
    NSLog(@"updateData called");
    
    if (self.forecastEngine) {
        // BUGBUG temp
        NSString * regionId = @"nwac_6";
        
        [self.forecastEngine forecastForRegionId:regionId 
            onCompletion:^(NSString * regionId, id forecastJSON)
            {
                RegionData * regionData = [self.regionsDict objectForKey:regionId];
                NSLog(@"onComletion called; regionId: %@; regionData: %@", regionId, regionData);
                if (regionData) {
                    // save the new data
                    regionData.forecastJSON = forecastJSON; 
                    
                    // update the annotation
                    [self recalcAnnotation: regionData];
                }
            }];
    }
}

- (IBAction) todayPressed:(id)sender
{
    NSLog(@"todayPressed called");
    
    self.mode = MODE_TODAY;
    self.todayButton.style = UIBarButtonItemStyleDone;
    self.tomorrowButton.style = UIBarButtonItemStyleBordered;
    
    [self recalcAnnotations];
}

- (IBAction) tomorrowPressed:(id)sender
{
    NSLog(@"tomorrowPressed called");
    
    self.mode = MODE_TOMORROW;
    self.tomorrowButton.style = UIBarButtonItemStyleDone;
    self.todayButton.style = UIBarButtonItemStyleBordered;

    [self recalcAnnotations];
}

- (void) didReceiveMemoryWarning
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
    
    
    
    // create the regions dictionary
    self.regionsDict = [NSMutableDictionary dictionary];
    
    // create the forecast engine
    self.forecastEngine = [[ForecastEngine alloc] init];

    
   
    // BUGBUG temp
    
    NSString * regionId = @"nwac_6";
    
    MKMapPoint p1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.476, -121.722));
    MKMapPoint p2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.391, -121.476));
    MKMapPoint p3 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.709, -121.130));
    MKMapPoint p4 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.861, -121.795));
    MKMapPoint pts[4] = {p1,p2,p3,p4};
    MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:4];

    RegionData * regionData = [[RegionData alloc] init];
    regionData.regionId = regionId;
    regionData.polygon = polygon; 
    regionData.forecastJSON = nil;
    regionData.overlayView = nil;
    
    // add it to our dictionary
    [self.regionsDict setObject:regionData forKey:regionId];

    // now add it to the map
    [self.map addOverlay:regionData];
    

    
    
    
    // fetch the data
    [self updateData:nil];
    
    // receive activation notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload
{
    [self setMap:nil];
    [self setTodayButton:nil];
    [self setTomorrowButton:nil];
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
