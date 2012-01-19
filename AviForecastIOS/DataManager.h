//
//  DataManager.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class ForecastEngine;

@interface DataManager : NSObject

// callback for data change notifications
typedef void (^DataUpdatedBlock)(NSString * regionId);

@property (strong, nonatomic) NSMutableDictionary * regionsDict;
@property (strong, nonatomic) ForecastEngine * forecastEngine;

- (void) loadRegions;
- (void) refreshForecasts:(DataUpdatedBlock) dataUpdatedBlock;

@end
