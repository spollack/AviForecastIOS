//
//  ForecastEngine.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

//
// manages all network access
//


@class RegionData;

@interface NetworkEngine : NSObject

// callback for errors
typedef void (^FailureResponseBlock)();

// callback for returning region data
typedef void (^RegionResponseBlock)(RegionData * regionData);

- (void) loadRegions:(RegionResponseBlock) completionBlock failure:(FailureResponseBlock) failureBlock;

// callback for returning forecast data
typedef void (^ForecastResponseBlock)(NSString * regionId, id forecastJSON);
 
- (void) forecastForRegionId:(NSString *) regionId 
    onCompletion:(ForecastResponseBlock) completionBlock;

@end
