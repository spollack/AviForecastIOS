//
//  DataManager.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "DataManager.h"
#import "RegionData.h"

@implementation DataManager

@synthesize regionsDict = _regionsDict;
@synthesize networkEngine = _networkEngine;

- (id) init
{
    return [self initWithNetworkActivityBlock:nil];
}

- (id) initWithNetworkActivityBlock:(NetworkActivityBlock)networkActivityBlock
{
    self = [super init];
    
    if (self) {
        self.regionsDict = [NSMutableDictionary dictionary];
        self.networkEngine = [[NetworkEngine alloc] initWithNetworkActivityBlock:networkActivityBlock];
    }
    
    return self;
}

- (void) loadForecastForRegionId:(NSString *) regionId onCompletion:(DataUpdatedBlock) forecastUpdatedBlock
{
    [self.networkEngine forecastForRegionId:regionId
        onCompletion:^(NSString * regionId, id forecastJSON)
        {
            RegionData * regionData = [self.regionsDict objectForKey:regionId];
            NSAssert(regionData, @"regionData should not be nil!");

            // save the new forecast data
            regionData.forecastJSON = forecastJSON;

            // invoke the callback
            forecastUpdatedBlock(regionId);
        }
    ];
}

- (void) loadRegions:(DataUpdatedBlock) regionAddedBlock failure:(FailureResponseBlock) failureBlock
{
    // load the regions data file, and then load the forecast data for each region that has been read
    
    [self.networkEngine loadRegions:
        ^(RegionData * regionData)
        {
            // add it to our dictionary
            [self.regionsDict setObject:regionData forKey:regionData.regionId];

            // load the forecast for this region
            [self loadForecastForRegionId:regionData.regionId onCompletion:regionAddedBlock];
        }
        failure:^()
        {
            failureBlock();
        }
    ];
}

- (void) reloadForecasts:(DataUpdatedBlock) forecastUpdatedBlock
{
    NSArray * allKeys = [self.regionsDict allKeys]; 
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key; 
        [self loadForecastForRegionId:regionId onCompletion:forecastUpdatedBlock];
    }
}

@end
