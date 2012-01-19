//
//  ViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class ForecastEngine;

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView * map;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tomorrowButton;
@property (strong, nonatomic) ForecastEngine * forecastEngine;
@property (strong, nonatomic) NSMutableDictionary * regionsDict;
@property BOOL haveUpdatedUserLocation;
@property int mode; 
- (IBAction)todayPressed:(id)sender;
- (IBAction)tomorrowPressed:(id)sender;

@end
