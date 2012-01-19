//
//  ViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class DataManager;
@class NetworkEngine;

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * map;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tomorrowButton;
@property (strong, nonatomic) DataManager * dataManager;
@property (strong, nonatomic) NSMutableDictionary * annotationsDict;
@property (nonatomic) BOOL haveUpdatedUserLocation;
@property (nonatomic) int mode; 
- (IBAction)todayPressed:(id)sender;
- (IBAction)tomorrowPressed:(id)sender;

@end
