//
//  ForecastEngine.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class RegionData;

@interface NetworkEngine : NSObject

// callback for returning configuration data
typedef void (^RegionResponseBlock)(RegionData * regionData);

- (void) loadRegions:(RegionResponseBlock) completionBlock;

// callback for returning forecast data
typedef void (^ForecastResponseBlock)(NSString * regionId, id forecastJSON);
 
- (void) forecastForRegionId:(NSString *) regionId 
    onCompletion:(ForecastResponseBlock) completionBlock;

@end
