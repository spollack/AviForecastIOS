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

@class DataManager;
@class NetworkEngine;

@interface MainViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, DetailsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * map;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tomorrowButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *twoDaysOutButton;
@property (strong, nonatomic) DataManager * dataManager;
@property (strong, nonatomic) NSMutableDictionary * overlayViewDict;
@property (nonatomic) BOOL haveUpdatedUserLocation;
@property (nonatomic) int mode; 
- (IBAction)todayPressed:(id)sender;
- (IBAction)tomorrowPressed:(id)sender;
- (IBAction)twoDaysOutPressed:(id)sender;

@end
