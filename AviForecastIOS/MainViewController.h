//
//  ViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//

//
// the main view
//


#import "DetailsViewController.h"
#import "DangerScaleViewController.h"

@class DataManager;
@class NetworkEngine;

@interface MainViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, DetailsViewControllerDelegate, DangerScaleViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * map;
@property (weak, nonatomic) IBOutlet UISegmentedControl * dayControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * spinner;
@property (strong, nonatomic) NSMutableDictionary * settings;
@property (strong, nonatomic) DataManager * dataManager;
@property (strong, nonatomic) NSMutableDictionary * overlayViewDict;
@property (nonatomic) BOOL haveUpdatedUserLocation;
@property (nonatomic) int mode; 

- (IBAction)dayPressed;
- (IBAction)legendPressed;
- (IBAction)infoPressed;

@end
