//
//  DataManager.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

//
// manages all region and forecast data
//


@class NetworkEngine;

@interface DataManager : NSObject

// callback for data change notifications
typedef void (^DataUpdatedBlock)(NSString * regionId);

@property (strong, nonatomic) NSMutableDictionary * regionsDict;
@property (strong, nonatomic) NetworkEngine * networkEngine;

- (void) loadRegions:(DataUpdatedBlock) regionAddedBlock;
- (void) loadForecastForRegionId:(NSString *) regionId onCompletion:(DataUpdatedBlock) forecastUpdatedBlock;
- (void) loadAllForecasts:(DataUpdatedBlock) forecastUpdatedBlock;

@end
