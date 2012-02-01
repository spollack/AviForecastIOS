//
//  DataManager.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "DataManager.h"
#import "RegionData.h"
#import "FlurryAnalytics.h"
#import "Counter.h"


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
    
    // start a counted, timed event
    Counter * counter = [[Counter alloc] initWithCount:0];
    NSLog(@"starting load regions");
    [FlurryAnalytics logEvent:@"LOAD_REGIONS" 
               withParameters:nil 
                        timed:YES];

    [self.networkEngine loadRegions:
        ^(RegionData * regionData)
        {
            // increment the count for each region loaded
            [counter incrementCount];
            
            // add it to our dictionary
            [self.regionsDict setObject:regionData forKey:regionData.regionId];

            // load the forecast for this region
            [self loadForecastForRegionId:regionData.regionId onCompletion:^(NSString * regionId) {

                // invoke the callback
                regionAddedBlock(regionId);

                // see if we have finished loading all the forecasts
                if ([counter decrementCount] == 0) {
                    NSLog(@"finished load regions");
                    [FlurryAnalytics endTimedEvent:@"LOAD_REGIONS" withParameters:nil];                
                }
            }];
        }
        failure:^()
        {
            NSLog(@"load regions failed");
            [FlurryAnalytics endTimedEvent:@"LOAD_REGIONS" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];

            failureBlock();
        }
    ];
}

- (void) reloadForecasts:(DataUpdatedBlock) forecastUpdatedBlock
{
    NSArray * allKeys = [self.regionsDict allKeys]; 
        
    // start a counted, timed event
    Counter * counter = [[Counter alloc] initWithCount:allKeys.count];
    NSLog(@"starting reload forecasts");
    [FlurryAnalytics logEvent:@"RELOAD_FORECASTS" 
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",counter.count], @"region count", nil] 
                        timed:YES];
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key; 
        [self loadForecastForRegionId:regionId onCompletion:^(NSString * regionId) {
            
            // invoke the callback
            forecastUpdatedBlock(regionId);
            
            // see if we have finished reloading all the forecasts
            if ([counter decrementCount] == 0) {
                NSLog(@"finished reload forecasts");
                [FlurryAnalytics endTimedEvent:@"RELOAD_FORECASTS" withParameters:nil];                
            }
        }];
    }
}

@end
