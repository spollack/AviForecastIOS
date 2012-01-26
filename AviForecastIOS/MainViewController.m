//
//  ViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "NetworkEngine.h"
#import "RegionData.h"
#import "DataManager.h"
#import "OverlayView.h"

// transparency level for overlays
#define OVERLAY_ALPHA 0.65

@implementation MainViewController

@synthesize map = _map;
@synthesize todayButton = _todayButton;
@synthesize tomorrowButton = _tomorrowButton;
@synthesize twoDaysOutButton = _twoDaysOutButton;
@synthesize dataManager = _dataManager;
@synthesize overlayViewDict = _overlayViewDict;
@synthesize haveUpdatedUserLocation = _haveUpdatedUserLocation;
@synthesize mode = _mode; 


- (void) detailsViewControllerDidFinish:(DetailsViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetails"]) {
        
        // tell the sub-view how to call back to this view
        [[segue destinationViewController] setDelegate:self];
        
        // find the URL associated with the selected view
        NSAssert(sender, @"sender should not be nil!");
        NSAssert([sender isKindOfClass:[OverlayView class]], @"sender should be of class OverlayView!");
        OverlayView * overlayView = (OverlayView *)sender;
        RegionData * regionData = [self.dataManager.regionsDict objectForKey:overlayView.regionId];
        NSAssert(regionData, @"regionData should not be nil!");
        NSAssert(regionData.URL, @"regionData.URL should not be nil!");
                
        NSURL * URL = [NSURL URLWithString:regionData.URL]; 

        // set the context for the details sub-view
        [[segue destinationViewController] setURL:URL];
    }
}

- (UIColor *) colorForAviLevel:(int)aviLevel
{
    UIColor * color = nil;
    
    switch (aviLevel) {
        case AVI_LEVEL_LOW: 
            color = [UIColor colorWithRed:(80/255.0) green:(184/255.0) blue:(72/255.0) alpha:OVERLAY_ALPHA];
            break;
        case AVI_LEVEL_MODERATE: 
            color = [UIColor colorWithRed:(255/255.0) green:(242/255.0) blue:(0/255.0) alpha:OVERLAY_ALPHA];
            break;
        case AVI_LEVEL_CONSIDERABLE: 
            color = [UIColor colorWithRed:(247/255.0) green:(148/255.0) blue:(30/255.0) alpha:OVERLAY_ALPHA];
            break;
        case AVI_LEVEL_HIGH: 
            color = [UIColor colorWithRed:(237/255.0) green:(28/255.0) blue:(36/255.0) alpha:OVERLAY_ALPHA];
            break;
        case AVI_LEVEL_EXTREME: 
            color = [UIColor colorWithRed:(35/255.0) green:(31/255.0) blue:(32/255.0) alpha:OVERLAY_ALPHA];
            break;
        default:
            color = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:OVERLAY_ALPHA];
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

            // default to a 300km x 300km view
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 300000, 300000); 
            [mapView setRegion:region animated:TRUE];

            self.haveUpdatedUserLocation = TRUE; 
        }
    }
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"viewForOverlay called");

    OverlayView * overlayView = nil;

    if ([overlay isKindOfClass:[RegionData class]]) {
        RegionData * regionData = (RegionData *)overlay; 
        overlayView = [[OverlayView alloc] initWithPolygon:regionData.polygon regionId:regionData.regionId]; 
        overlayView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:OVERLAY_ALPHA];
        overlayView.lineWidth = 2;

        // set the overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];                        
        overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // add it to our dictionary
        [self.overlayViewDict setObject:overlayView forKey:regionData.regionId];
    }
        
    return overlayView;
}

- (void) refreshOverlay:(NSString *)regionId
{
    OverlayView * overlayView = (OverlayView *)[self.overlayViewDict objectForKey:regionId];

    // we may or may not have a view for this overlay
    if (overlayView) {
        
        // look up the region data
        RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
        NSAssert(regionData, @"regionData should not be nil!");
        
        NSLog(@"refreshing overlay for regionId: %@", regionData.regionId);

        // set the aviLevel-based overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];
        overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // redraw the overlay
        [overlayView setNeedsDisplay];
    }
}

- (void) refreshOverlays
{
    NSLog(@"refreshOverlays called");

    NSArray * allKeys = [self.overlayViewDict allKeys];
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key;
        [self refreshOverlay: regionId];
    }
}

- (void) updateData: (id)notification {
    NSLog(@"updateData called");
    
    // load the forecasts, then refresh each overlay as new data arrives
    [self.dataManager loadForecasts:
        ^(NSString * regionId) {
            [self refreshOverlay:regionId];
        }
    ];
}

- (IBAction) todayPressed:(id)sender
{
    NSLog(@"todayPressed called");
    
    if (self.mode != MODE_TODAY) {
        self.mode = MODE_TODAY;
        self.todayButton.style = UIBarButtonItemStyleDone;
        self.tomorrowButton.style = UIBarButtonItemStyleBordered;
        self.twoDaysOutButton.style = UIBarButtonItemStyleBordered;
        
        [self refreshOverlays];
    }
}

- (IBAction) tomorrowPressed:(id)sender
{
    NSLog(@"tomorrowPressed called");
    
    if (self.mode != MODE_TOMORROW) {
        self.mode = MODE_TOMORROW;
        self.todayButton.style = UIBarButtonItemStyleBordered;
        self.tomorrowButton.style = UIBarButtonItemStyleDone;
        self.twoDaysOutButton.style = UIBarButtonItemStyleBordered;

        [self refreshOverlays];
    }
}

- (IBAction)twoDaysOutPressed:(id)sender
{
    NSLog(@"twoDaysOutPressed called");
    
    if (self.mode != MODE_TWO_DAYS_OUT) {
        self.mode = MODE_TWO_DAYS_OUT;
        self.todayButton.style = UIBarButtonItemStyleBordered;
        self.tomorrowButton.style = UIBarButtonItemStyleBordered;
        self.twoDaysOutButton.style = UIBarButtonItemStyleDone;
        
        [self refreshOverlays];
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
            shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // allow our gesture recognition to co-exist with recognition built-in to the map
    return YES;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint touchPoint = [tapGestureRecognizer locationInView:self.map];
    CLLocationCoordinate2D touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    MKMapPoint mapPoint = MKMapPointForCoordinate(touchMapCoordinate);

    // BUGBUG this hit-testing becomes inefficient as the number of regions grows...
    
    NSArray * allValues = [self.overlayViewDict allValues];
    
    for (id value in allValues) {
        OverlayView * overlayView = (OverlayView *)value;
        CGPoint polygonViewPoint = [overlayView pointForMapPoint:mapPoint];
        BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(overlayView.path, NULL, polygonViewPoint, NO);
        
        if (mapCoordinateIsInPolygon) {
            NSLog(@"tap in overlay detected; regionId: %@", overlayView.regionId);
            
            // respond to the selection by segueing to the details view
            [self performSegueWithIdentifier:@"showDetails" sender:overlayView];     

            break;
        }
    }
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
    
    NSLog(@"MainViewController viewDidLoad called");

    // NOTE local initialization has to happen here, not in the init method, for UIViewController classes
    self.dataManager = [[DataManager alloc] init];
    self.overlayViewDict = [NSMutableDictionary dictionary];
    self.haveUpdatedUserLocation = FALSE; 
    self.mode = MODE_TODAY;
    
    // set up tap recognition for our overlays on the map
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGestureRecognizer.delegate = self;
    [self.map addGestureRecognizer:tapGestureRecognizer];

    // initialize the data manager with the regions
    [self.dataManager loadRegions:^(NSString * regionId) {
        RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
        NSAssert(regionData, @"regionData should not be nil!");

        // add it to the map as an overlay (overlay data, not overlay view)
        [self.map addOverlay:regionData];
        
        // load the forecast data for the region
        [self.dataManager loadForecastForRegionId:regionId 
            onCompletion:^(NSString *regionId)
            {
                [self refreshOverlay:regionId];
            }
        ];
    }];
    
    // receive app activation notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [self.map setDelegate:nil];
    [self setMap:nil];
    [self setTodayButton:nil];
    [self setTomorrowButton:nil];
    [self setTwoDaysOutButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
