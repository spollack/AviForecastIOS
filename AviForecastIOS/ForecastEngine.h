//
//  ForecastEngine.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface ForecastEngine : NSObject

// callback for returning the data
typedef void (^ForecastResponseBlock)(NSString * regionId, id forecastJSON);
 
- (void) forecastForRegionId:(NSString *) regionId 
    onCompletion:(ForecastResponseBlock) completionBlock;

@end
