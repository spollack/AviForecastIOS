//
//  ViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "MainViewController.h"
#import "NetworkEngine.h"
#import "RegionData.h"
#import "DataManager.h"
#import "OverlayView.h"
#import "FlurryAnalytics.h"


// transparency level for overlays
#define OVERLAY_ALPHA 0.65

// map region, in meters, horizontally and vertically, to display by default
#define MAP_VIEW_DEFAULT_METERS 300000

@implementation MainViewController

@synthesize map = _map;
@synthesize todayButton = _todayButton;
@synthesize tomorrowButton = _tomorrowButton;
@synthesize twoDaysOutButton = _twoDaysOutButton;
@synthesize dataManager = _dataManager;
@synthesize overlayViewDict = _overlayViewDict;
@synthesize haveUpdatedUserLocation = _haveUpdatedUserLocation;
@synthesize mode = _mode; 


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

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // once we have the user's actual location, center and zoom in; however, only do this once, 
    // so the map doesn't keep jumping around
    
    if (!self.haveUpdatedUserLocation) {
        
        CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;
        
        if (location.latitude < 0.1 && location.longitude < 0.1) {
            // this can happen if the user does not allow the app to access their location
            NSLog(@"reported user location is near (0,0), not updating");
        } else {
            NSLog(@"updating map position based on user location");

            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, MAP_VIEW_DEFAULT_METERS, MAP_VIEW_DEFAULT_METERS); 
            [mapView setRegion:region animated:TRUE];
            
            // record an event
            [FlurryAnalytics setLatitude:userLocation.location.coordinate.latitude
                      longitude:userLocation.location.coordinate.longitude
                      horizontalAccuracy:userLocation.location.horizontalAccuracy
                      verticalAccuracy:userLocation.location.verticalAccuracy]; 

            self.haveUpdatedUserLocation = TRUE; 
        }
    }
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    OverlayView * overlayView = nil;

    if ([overlay isKindOfClass:[RegionData class]]) {
        RegionData * regionData = (RegionData *)overlay; 
        overlayView = [[OverlayView alloc] initWithPolygon:regionData.polygon regionId:regionData.regionId]; 
        overlayView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:OVERLAY_ALPHA];
        overlayView.lineWidth = 2;

        // set the aviLevel-based overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];                        
        overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // add it to our dictionary of views
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

- (void) refreshAllOverlays
{
    NSLog(@"refreshAllOverlays called");

    NSArray * allKeys = [self.overlayViewDict allKeys];
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key;
        [self refreshOverlay: regionId];
    }
}

- (void) updateAllForecastData:(id)notification
{
    NSLog(@"updateAllForecastData called");
    
    // load the forecasts, then refresh each overlay as new data arrives
    [self.dataManager loadAllForecasts:
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
        
        [self refreshAllOverlays];
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

        [self refreshAllOverlays];
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
        
        [self refreshAllOverlays];
    }
}

- (void) showDetailsView:(NSString *)regionId
{
    DetailsViewController * detailsViewController = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
    detailsViewController.delegate = self;
    detailsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;


    // find the URL associated with the selected region, and set it in the view
    RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
    NSAssert(regionData, @"regionData should not be nil!");
    NSAssert(regionData.URL, @"regionData.URL should not be nil!");
    NSURL * URL = [NSURL URLWithString:regionData.URL]; 
    
    [detailsViewController setURL:URL];
    
    NSLog(@"about to go to details view");
    
    // log an event
    [FlurryAnalytics logEvent:@"OPEN_DETAILS_VIEW" 
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:regionId, @"regionId", nil]];
    
    [self presentModalViewController:detailsViewController animated:YES];
}

- (void) detailsViewControllerDidFinish:(DetailsViewController *)controller
{
    // this method is called by the detail view, when its time for the details view to go away
    
    NSLog(@"about to return from details view");

    [self dismissModalViewControllerAnimated:YES];
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

    // do our hit-testing, to see if the user tapped in a region
    // NOTE this hit-testing will become inefficient as the number of regions grows, as we are doing linear search;
    // if neccesary, we could do a smarter search (e.g., filter the polygon set to hit-test based on their bounding boxes)
    
    NSArray * allValues = [self.overlayViewDict allValues];
    
    for (id value in allValues) {
        OverlayView * overlayView = (OverlayView *)value;
        CGPoint polygonViewPoint = [overlayView pointForMapPoint:mapPoint];
        BOOL mapCoordinateIsInPolygon = CGPathContainsPoint(overlayView.path, NULL, polygonViewPoint, NO);
        
        if (mapCoordinateIsInPolygon) {
            NSLog(@"tap in overlay detected; regionId: %@", overlayView.regionId);
            
            // respond to the selection by changing to the details view
            [self showDetailsView:overlayView.regionId];     

            break;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSLog(@"MainViewController viewDidLoad called");

    // NOTE local initialization has to happen here for UIViewController classes, not in the init method
    self.dataManager = [[DataManager alloc] init];
    self.overlayViewDict = [NSMutableDictionary dictionary];
    self.haveUpdatedUserLocation = FALSE; 
    self.mode = MODE_TODAY;
    
    // NOTE set our user agent string to something benign and non-mobile looking, to work around website
    // popups (from nwac.us) asking if you would like to be redirected to the mobile version of the site
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];  

    // set up tap recognition for our overlays on the map
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGestureRecognizer.delegate = self;
    [self.map addGestureRecognizer:tapGestureRecognizer];

    // initialize the data manager with the regions
    [self.dataManager loadRegions:^(NSString * regionId) {
        
        // load the forecast data for the region
        [self.dataManager loadForecastForRegionId:regionId 
            onCompletion:^(NSString *regionId)
            {
                RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
                NSAssert(regionData, @"regionData should not be nil!");
                
                // add the region to the map as an overlay (overlay data, not overlay view)
                [self.map addOverlay:regionData];
            }
        ];
    }];
    
    // register so that on app re-entering the foreground, we update our forecasts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllForecastData:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidUnload
{
    NSLog(@"MainViewController viewDidUnload called");

    [self.map setDelegate:nil];
    [self setMap:nil];
    [self setTodayButton:nil];
    [self setTomorrowButton:nil];
    [self setTwoDaysOutButton:nil];
    [self setDataManager:nil];
    [self setOverlayViewDict:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // the main view only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
