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

// alert titles
#define DISCLAIMER_ALERT @"Disclaimer"
#define NETWORK_ERROR_ALERT @"Network Error"

// settings
#define SETTINGS_FILE_NAME @"settings.plist"
#define ACCEPTED_DISCLAIMER_KEY @"AcceptedDisclaimer"


@implementation MainViewController

@synthesize map = _map;
@synthesize dayControl = _dayControl;
@synthesize settings = _settings;
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

- (IBAction) dayPressed
{
    int newMode = self.dayControl.selectedSegmentIndex; 

    NSLog(@"dayPressed called, new mode is: %i", newMode);

    if (newMode != self.mode) {
        self.mode = self.mode;
        
        [self refreshAllOverlays];
    }
}

- (void) showDangerScaleView
{
    DangerScaleViewController * dangerScaleViewController = [[DangerScaleViewController alloc] initWithNibName:@"DangerScaleViewController" bundle:nil];
    dangerScaleViewController.delegate = self;
    dangerScaleViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
    NSLog(@"starting danger scale view");
    
    [self presentModalViewController:dangerScaleViewController animated:YES];
}

- (void) dangerScaleViewControllerDidFinish:(DangerScaleViewController *)controller
{
    // this method is called by the danger scale view, when its time for that view to go away
    
    NSLog(@"finished danger scale view");
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)legendPressed:(id)sender {
    [self showDangerScaleView];
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
    
    NSLog(@"starting details view");
    
    // log a timed event
    [FlurryAnalytics logEvent:@"DETAILS_VIEW" 
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:regionId, @"regionId", nil] timed:YES];
    
    [self presentModalViewController:detailsViewController animated:YES];
}

- (void) detailsViewControllerDidFinish:(DetailsViewController *)controller
{
    // this method is called by the detail view, when its time for that view to go away
    
    NSLog(@"finished details view");
    
    // close the timed event
    [FlurryAnalytics endTimedEvent:@"DETAILS_VIEW" withParameters:nil];

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

- (void) updateAllForecastData:(id)notification
{
    NSLog(@"updateAllForecastData called");
    
    // load the forecasts, then refresh each overlay as new data arrives
    [self.dataManager loadForecasts:
        ^(NSString * regionId) {
            [self refreshOverlay:regionId];
        }
        success:^() {}
        failure:^() {}
    ];
}

- (void)loadData
{
    [self.dataManager loadRegions:
        ^(NSString * regionId) {
            
            RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
            NSAssert(regionData, @"regionData should not be nil!");
            
            // add the region to the map as an overlay (overlay data, not overlay view)
            [self.map addOverlay:regionData];
        }
        success:^() {}
        failure:^() {
            [FlurryAnalytics logEvent:@"Could not load regions data"];
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NETWORK_ERROR_ALERT message:@"Could not load forecast regions; do you have internet access?" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [alertView show];
        }
    ];
}

- (void)showDisclaimerIfNeeded
{
    if (![self.settings objectForKey:ACCEPTED_DISCLAIMER_KEY])
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:DISCLAIMER_ALERT message:@"This information is provided 'as is'; accuracy or reliability is not guaranteed or warranted in any way. In no event shall the providers be liable for any damages (including, without limitation, injury or death) arising out of the use of, or inability to use, the information." delegate:self cancelButtonTitle:@"I Agree" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)loadSettings
{
    // load the settings
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:SETTINGS_FILE_NAME];
    self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (!self.settings) {
        self.settings = [NSMutableDictionary dictionary];
    }
}

- (void)saveSettings
{
    // save the settings
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:SETTINGS_FILE_NAME];
    [self.settings writeToFile:plistPath atomically:YES];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.title == DISCLAIMER_ALERT) {
        // update the settings to show disclaimer has been accepted
        [self.settings setObject:@"yes" forKey:ACCEPTED_DISCLAIMER_KEY];
        [self saveSettings];
    } 
    else if (alertView.title == NETWORK_ERROR_ALERT) {
        // try loading the data again
        [self loadData];
    }
}

- (void)completeInitialization
{
    self.dataManager = [[DataManager alloc] init];
    self.overlayViewDict = [NSMutableDictionary dictionary];
    self.haveUpdatedUserLocation = FALSE; 
    self.mode = MODE_TODAY;
    
    // set up tap recognition for our overlays on the map
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGestureRecognizer.delegate = self;
    [self.map addGestureRecognizer:tapGestureRecognizer];
    
    // load the regions and forecasts
    [self loadData];
    
    // NOTE set our user agent string to something benign and non-mobile looking, to work around website
    // popups (from nwac.us) asking if you would like to be redirected to the mobile version of the site
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];  
    
    // register so that on app re-entering the foreground, we update our forecasts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllForecastData:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"MainViewController viewDidLoad called");
    
    // NOTE local initialization has to happen here for UIViewController classes, not in the init method
    
    [self loadSettings];
    
    [self showDisclaimerIfNeeded];
    
    [self completeInitialization];
}

- (void)viewDidUnload
{
    NSLog(@"MainViewController viewDidUnload called");

    [self.map setDelegate:nil];
    [self setMap:nil];
    [self setDayControl:nil];
    [self setSettings:nil];
    [self setDataManager:nil];
    [self setOverlayViewDict:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // this view only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
