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
#import "DataManager.h"

@implementation ViewController

@synthesize map = _map;
@synthesize todayButton = _todayButton;
@synthesize tomorrowButton = _tomorrowButton;
@synthesize dataManager = _dataManager;
@synthesize annotationsDict = _annotationsDict;
@synthesize haveUpdatedUserLocation = _haveUpdatedUserLocation;
@synthesize mode = _mode; 

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

- (void) mapView:(MKMapView *)mapView
    didUpdateUserLocation:(MKUserLocation *)userLocation
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
        
        // add it to our dictionary
        [self.annotationsDict setObject:overlayView forKey:regionData.regionId];
    }
        
    return overlayView;
}

- (void) refreshAnnotation:(NSString *)regionId
{
    MKPolygonView * overlayView = (MKPolygonView *)[self.annotationsDict objectForKey:regionId];

    if (overlayView) {
        // look up the region data
        RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
        NSAssert(regionData,@"regionData should not be nil!");
        
        NSLog(@"refreshing annotation for regionId: %@", regionData.regionId);

        // set the aviLevel-based overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];
        overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // redraw the annotation
        [overlayView setNeedsDisplay];
    }
}

- (void) refreshAnnotations
{
    NSLog(@"refreshAnnotations called");

    NSArray * allKeys = [self.annotationsDict allKeys];
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key;
        [self refreshAnnotation: regionId];
    }
}

- (void) updateData: (id)notification {
    NSLog(@"updateData called");
    
    [self.dataManager refreshForecasts:
        ^(NSString * regionId) {
            [self refreshAnnotation:regionId];
        }
    ];
    
    [self refreshAnnotations];
}

- (IBAction) todayPressed:(id)sender
{
    NSLog(@"todayPressed called");
    
    self.mode = MODE_TODAY;
    self.todayButton.style = UIBarButtonItemStyleDone;
    self.tomorrowButton.style = UIBarButtonItemStyleBordered;
    
    [self refreshAnnotations];
}

- (IBAction) tomorrowPressed:(id)sender
{
    NSLog(@"tomorrowPressed called");
    
    self.mode = MODE_TOMORROW;
    self.tomorrowButton.style = UIBarButtonItemStyleDone;
    self.todayButton.style = UIBarButtonItemStyleBordered;

    [self refreshAnnotations];
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

    
    self.dataManager = [[DataManager alloc] init];
    self.annotationsDict = [NSMutableDictionary dictionary];
    self.haveUpdatedUserLocation = FALSE; 
    self.mode = MODE_TODAY;

    
    
   
    // BUGBUG temp; hardcoded; and restructure into DataManager
    
    NSString * regionId = @"nwac_6";
    
    MKMapPoint p1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.476, -121.722));
    MKMapPoint p2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.391, -121.476));
    MKMapPoint p3 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.709, -121.130));
    MKMapPoint p4 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.861, -121.795));
    MKMapPoint pts[4] = {p1,p2,p3,p4};
    MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:4];

    RegionData * regionData = [[RegionData alloc] initWithRegionId:regionId andPolygon:polygon];
    
    // add it to our dictionary
    [self.dataManager.regionsDict setObject:regionData forKey:regionId];

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
