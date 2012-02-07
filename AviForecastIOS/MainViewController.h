//
//  ViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

//
// the main view
//


#import "DetailsViewController.h"
#import "DangerScaleViewController.h"

@class DataManager;
@class NetworkEngine;

@interface MainViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, DetailsViewControllerDelegate, DangerScaleViewControllerDelegate, UIAlertViewDelegate>

// NOTE if we drop iOS4.x support, change "unsafe_unretained" to "weak"

@property (unsafe_unretained, nonatomic) IBOutlet MKMapView * map;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *tomorrowButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *twoDaysOutButton;
@property (strong, nonatomic) DataManager * dataManager;
@property (strong, nonatomic) NSMutableDictionary * overlayViewDict;
@property (nonatomic) BOOL haveUpdatedUserLocation;
@property (nonatomic) int mode; 
- (IBAction)todayPressed:(id)sender;
- (IBAction)tomorrowPressed:(id)sender;
- (IBAction)twoDaysOutPressed:(id)sender;
- (IBAction)legendPressed:(id)sender;

@end
