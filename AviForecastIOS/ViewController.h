//
//  ViewController.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ForecastEngine.h"

@interface ViewController : UIViewController
@property (strong, nonatomic) ForecastEngine *forecastEngine;
@property (weak, nonatomic) IBOutlet UILabel *levelDisplay;

@end
