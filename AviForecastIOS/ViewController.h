//
//  ViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class ForecastEngine;

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) ForecastEngine * forecastEngine;
@property (weak, nonatomic) IBOutlet MKMapView * map;
@property BOOL haveUpdatedUserLocation;
@property (strong, nonatomic) NSMutableDictionary * regionsDict;


@end
