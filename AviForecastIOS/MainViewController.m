//
//  ViewController.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//

#import "MainViewController.h"
#import "NetworkEngine.h"
#import "RegionData.h"
#import "DataManager.h"
#import "OverlayView.h"
#import "Flurry.h"


// transparency level for overlays
#define OVERLAY_ALPHA 0.65

// map region, in meters, horizontally and vertically, to display by default
#define MAP_VIEW_DEFAULT_METERS 300000

// application persistent settings management
#define SETTINGS_FILE_NAME @"settings.plist"
#define ACCEPTED_DISCLAIMER_KEY @"AcceptedDisclaimer"

// alerts
#define DISCLAIMER_ALERT_TITLE @"Warranty Disclaimer"
#define DISCLAIMER_ALERT_TEXT @"This product, including all information shown, is provided 'as is'. Sebnarware makes no warranty or representation of any kind. Sebnarware does not warrant that the product or information is error free, nor that service will be uninterrupted. In no event shall Sebnarware be liable for any damages (including without limitation, where use of the product could lead to death or personal injury)."
#define DISCLAIMER_ALERT_BUTTON_TITLE @"I Agree"

#define HOW_TO_USE_ALERT_TITLE @"How To Use"
#define HOW_TO_USE_ALERT_TEXT @"- Each avalanche forecast region is colored based on the overall danger level\n\n- Use the buttons at the bottom to select the forecast timeframe\n\n- Tap the top legend to see descriptions of the danger levels\n\n- Tap a region on the map to go to the detailed avalanche forecast\n\n- Even regions shown as \"No Rating\" on the map often have more information available in the detailed forecast\n\nAvalanche Forecasts iOS v%@ (%@)"
#define HOW_TO_USE_ALERT_BUTTON_TITLE @"Ok"

#define NETWORK_ERROR_ALERT_TITLE @"Network Error"
#define NETWORK_ERROR_ALERT_TEXT @"Could not load forecast regions; do you have internet access?"
#define NETWORK_ERROR_ALERT_BUTTON_TITLE @"Try Again"


@implementation MainViewController

@synthesize map = _map;
@synthesize dayControl = _dayControl;
@synthesize settings = _settings;
@synthesize dataManager = _dataManager;
@synthesize overlayViewDict = _overlayViewDict;
@synthesize spinner = _spinner;
@synthesize haveUpdatedUserLocation = _haveUpdatedUserLocation;
@synthesize mode = _mode; 


- (UIColor *) colorForAviLevel:(int)aviLevel
{
    UIColor * color = nil;
    
    // colors are from the North American Public Avalanche Danger Scale color specification
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
    // so the map doesn't keep jumping around as location update events occur
    
    if (!self.haveUpdatedUserLocation) {
        
        CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;
        
        if (location.latitude < 0.1 && location.longitude < 0.1) {
            // NOTE this can happen if the user did not (yet) allow the app to access their location
            DLog(@"reported user location is near (0,0), not updating");
        } else {
            DLog(@"updating map position based on user location");

            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, MAP_VIEW_DEFAULT_METERS, MAP_VIEW_DEFAULT_METERS); 
            [mapView setRegion:region animated:TRUE];
            
            // record an event
#ifndef DEBUG
            [Flurry setLatitude:userLocation.location.coordinate.latitude
                      longitude:userLocation.location.coordinate.longitude
                      horizontalAccuracy:userLocation.location.horizontalAccuracy
                      verticalAccuracy:userLocation.location.verticalAccuracy]; 
#endif
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
        [self setStandardOutline:overlayView];

        // set the aviLevel-based overlay color
        int aviLevel = [regionData aviLevelForMode: self.mode];                        
        overlayView.fillColor = [self colorForAviLevel: aviLevel];
        
        // add it to our dictionary of views
        [self.overlayViewDict setObject:overlayView forKey:regionData.regionId];
    }
        
    return overlayView;
}

- (void)setStandardOutline:(OverlayView *)overlayView
{
    overlayView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:OVERLAY_ALPHA];
    overlayView.lineWidth = 2;
}

- (void)setHighlightOutline:(OverlayView *)overlayView
{
    overlayView.strokeColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(128/255.0) alpha:OVERLAY_ALPHA];
    overlayView.lineWidth = 5;
}

- (void) highlightOverlay:(OverlayView *)overlayView
{
    [self setHighlightOutline:overlayView];
    
    // redraw the overlay
    [overlayView setNeedsDisplay];
}

- (void) unhighlightOverlay:(OverlayView *)overlayView
{
    [self setStandardOutline:overlayView];
    
    // redraw the overlay
    [overlayView setNeedsDisplay];
}

- (void) refreshOverlay:(NSString *)regionId
{
    OverlayView * overlayView = (OverlayView *)[self.overlayViewDict objectForKey:regionId];

    // we may or may not have a view for this overlay
    if (overlayView) {
        
        // look up the region data
        RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
        
        if (!regionData) {
            NSAssert(false, @"regionData should not be nil!");
        } else {        
            DLog(@"refreshing overlay for regionId: %@", regionData.regionId);

            // set the aviLevel-based overlay color
            int aviLevel = [regionData aviLevelForMode: self.mode];
            overlayView.fillColor = [self colorForAviLevel: aviLevel];
            
            // redraw the overlay
            [overlayView setNeedsDisplay];
        }
    }
}

- (void) refreshAllOverlays
{
    DLog(@"refreshAllOverlays called");

    NSArray * allKeys = [self.overlayViewDict allKeys];
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key;
        [self refreshOverlay: regionId];
    }
}

- (IBAction) dayPressed
{
    int newMode = self.dayControl.selectedSegmentIndex; 

    DLog(@"dayPressed called, new mode is: %i", newMode);

    if (newMode != self.mode) {
        self.mode = newMode;
        
        [self refreshAllOverlays];
    }
}

- (void) showDangerScaleView
{
    DangerScaleViewController * dangerScaleViewController = [[DangerScaleViewController alloc] initWithNibName:@"DangerScaleViewController" bundle:nil];
    dangerScaleViewController.delegate = self;
    dangerScaleViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
    DLog(@"starting danger scale view");
    
    [self presentModalViewController:dangerScaleViewController animated:YES];
}

- (void) dangerScaleViewControllerDidFinish:(DangerScaleViewController *)controller
{
    // this method is called by the danger scale view, when its time for that view to go away
    
    DLog(@"finished danger scale view");
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)legendPressed {
    [self showDangerScaleView];
}

- (void) showDetailsView:(NSString *)regionId
{
    DetailsViewController * detailsViewController = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
    detailsViewController.delegate = self;
    detailsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
    
    if (!regionData) {
        NSAssert(false, @"regionData should not be nil!");
    } else {
        if (!regionData.URL) {
            NSAssert(false, @"regionData.URL should not be nil!");
        } else {
            // inform the view of the URL and region name for the selected region
            NSURL * URL = [NSURL URLWithString:regionData.URL]; 
            [detailsViewController setURL:URL];
            [detailsViewController setCustomTitle:regionData.displayName];
            
            DLog(@"starting details view");
            
            // log a timed event
#ifndef DEBUG
            [Flurry logEvent:@"DETAILS_VIEW" 
                       withParameters:[NSDictionary dictionaryWithObjectsAndKeys:regionId, @"regionId", nil] timed:YES];
#endif            
            [self presentModalViewController:detailsViewController animated:YES];
        }
    }
}

- (void) detailsViewControllerDidFinish:(DetailsViewController *)controller
{
    // this method is called by the detail view, when its time for that view to go away
    
    DLog(@"finished details view");
    
    // close the timed event
#ifndef DEBUG
    [Flurry endTimedEvent:@"DETAILS_VIEW" withParameters:nil];
#endif
    
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
            DLog(@"tap in overlay detected; regionId: %@", overlayView.regionId);
            
            // highlight the selected region
            [self highlightOverlay:overlayView];
            
            // wait a short bit
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // respond to the selection by changing to the details view
                [self showDetailsView:overlayView.regionId];

                // turn off the highlight
                [self unhighlightOverlay:overlayView];
            });

            break;
        }
    }
}

- (void) updateAllForecastData:(id)notification
{
    DLog(@"updateAllForecastData called");
    
    [self.spinner startAnimating];

    // load the forecasts, then refresh each overlay as new data arrives
    [self.dataManager loadForecasts:
        ^(NSString * regionId) {
            [self refreshOverlay:regionId];
        }
        success:^() {
            [self.spinner stopAnimating];
        }
        failure:^() {
            [self.spinner stopAnimating];
        }
    ];
}

- (void)loadData
{
    DLog(@"loadData called");

    [self.spinner startAnimating];

    [self.dataManager loadRegions:
        ^(NSString * regionId) {
            
            RegionData * regionData = [self.dataManager.regionsDict objectForKey:regionId];
            
            if (!regionData) {
                NSAssert(false, @"regionData should not be nil!");
            } else {
                // add the region to the map as an overlay (overlay data, not overlay view)
                [self.map addOverlay:regionData];
            }
        }
        success:^() {
            [self.spinner stopAnimating];
        }
        failure:^() {
            [self.spinner stopAnimating];
#ifndef DEBUG
            [Flurry logEvent:@"INITIAL_DATA_LOAD_FAILED"];
#endif
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NETWORK_ERROR_ALERT_TITLE message:NETWORK_ERROR_ALERT_TEXT delegate:self cancelButtonTitle:NETWORK_ERROR_ALERT_BUTTON_TITLE otherButtonTitles:nil];
            [alertView show];
        }
    ];
}

- (void)showDisclaimerIfNeeded
{
    if (![self.settings objectForKey:ACCEPTED_DISCLAIMER_KEY])
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:DISCLAIMER_ALERT_TITLE message:DISCLAIMER_ALERT_TEXT delegate:self cancelButtonTitle:DISCLAIMER_ALERT_BUTTON_TITLE otherButtonTitles:nil];
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

- (IBAction)infoPressed {
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; 
    NSString * build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; 
    NSString * alertText = [NSString stringWithFormat:HOW_TO_USE_ALERT_TEXT, version, build];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:HOW_TO_USE_ALERT_TITLE message:alertText delegate:self cancelButtonTitle:HOW_TO_USE_ALERT_BUTTON_TITLE otherButtonTitles:nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:DISCLAIMER_ALERT_TITLE]) {
        // update the settings to show disclaimer has been accepted
        [self.settings setObject:@"yes" forKey:ACCEPTED_DISCLAIMER_KEY];
        [self saveSettings];
    } 
    else if ([alertView.title isEqualToString:NETWORK_ERROR_ALERT_TITLE]) {
        // try loading the data again
        [self loadData];
    }
    else if ([alertView.title isEqualToString:HOW_TO_USE_ALERT_TITLE]) {
        // do nothing
    }
}

- (void)completeInitialization
{
    self.dataManager = [[DataManager alloc] init];
    self.overlayViewDict = [NSMutableDictionary dictionary];
    self.haveUpdatedUserLocation = FALSE; 
    self.mode = MODE_TODAY;
    
    [self loadSettings];

    // set up tap recognition for our overlays on the map
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    tapGestureRecognizer.delegate = self;
    [self.map addGestureRecognizer:tapGestureRecognizer];
    
    // load the regions and forecasts
    [self loadData];
    
    // register so that on app re-entering the foreground, we update our forecasts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllForecastData:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // NOTE set our user agent string to something benign and non-mobile looking, to work around website
    // popups from nwac.us asking if you would like to be redirected to the mobile version of the site
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Mozilla/5.0", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DLog(@"MainViewController viewDidLoad called");
    
    // NOTE local initialization has to happen here for UIViewController sub-classes, not in the init method
    [self completeInitialization];
    
    [self showDisclaimerIfNeeded];
}

- (void)viewDidUnload
{
    DLog(@"MainViewController viewDidUnload called");

    [self.map setDelegate:nil];
    [self setMap:nil];
    [self setDayControl:nil];
    [self setSettings:nil];
    [self setDataManager:nil];
    [self setOverlayViewDict:nil];
    
    [self setSpinner:nil];
    [super viewDidUnload];
}

// for iOS6+
- (BOOL)shouldAutorotate
{
    return NO;
}

// for iOS6+
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// for iOS5 and earlier
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // this view only supports portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
