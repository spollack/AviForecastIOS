//
//  DataManager.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
//

#import "DataManager.h"
#import "NetworkEngine.h"
#import "RegionData.h"
#import "Flurry.h"


@implementation DataManager

@synthesize regionsDict = _regionsDict;
@synthesize networkEngine = _networkEngine;

- (id) init
{
    self = [super init];
    
    if (self) {
        self.regionsDict = [NSMutableDictionary dictionary];
        self.networkEngine = [[NetworkEngine alloc] init];
    }
    
    return self;
}

- (void) loadRegions:(DataUpdatedBlock)dataUpdatedBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock
{
    // load the regions data, and then load the forecasts data
    // NOTE the dataUpdatedBlock callback will only be called once the forecast data is loaded
    
    // start timed events
    DLog(@"starting initial data load");
#ifndef DEBUG
    [Flurry logEvent:@"INITIAL_DATA_LOAD" 
               withParameters:nil 
                        timed:YES];
#endif
    DLog(@"starting load regions");
#ifndef DEBUG
    [Flurry logEvent:@"LOAD_REGIONS" 
               withParameters:nil 
                        timed:YES];
#endif
    
    [self.networkEngine loadRegions:
        ^(RegionData * regionData)
        {
            // add it to our dictionary
            [self.regionsDict setObject:regionData forKey:regionData.regionId];
        }
        success:^()
        {
            DLog(@"finished load regions");
#ifndef DEBUG
            [Flurry endTimedEvent:@"LOAD_REGIONS" withParameters:nil];
#endif            
            // now that we have the regions, load the forecasts
            [self loadForecasts:dataUpdatedBlock
                success:^()
                {
                    DLog(@"finished initial data load");
#ifndef DEBUG
                    [Flurry endTimedEvent:@"INITIAL_DATA_LOAD" withParameters:nil];
#endif
                    successBlock();
                }
                failure:^()
                {
                    DLog(@"initial data load failed");
#ifndef DEBUG
                    [Flurry endTimedEvent:@"INITIAL_DATA_LOAD" 
                                    withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
#endif                    
                    failureBlock();
                }
            ];
        }
        failure:^()
        {
            DLog(@"load regions failed");
#ifndef DEBUG
            [Flurry endTimedEvent:@"LOAD_REGIONS" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
#endif
            DLog(@"initial data load failed");
#ifndef DEBUG
            [Flurry endTimedEvent:@"INITIAL_DATA_LOAD" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
#endif
            failureBlock();
        }
    ];
}

- (void) loadForecasts:(DataUpdatedBlock)dataUpdatedBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock
{
    // start timed event
    DLog(@"starting load forecasts");
#ifndef DEBUG
    [Flurry logEvent:@"LOAD_FORECASTS" 
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",self.regionsDict.count], @"region count", nil] 
                        timed:YES];
#endif
    
    [self.networkEngine loadForecasts:
        ^(NSString * regionId, id forecastJSON)
        {
            RegionData * regionData = [self.regionsDict objectForKey:regionId];
            
            // NOTE regionData could be nil, if we are serving forecasts for regions that this client isn't aware of yet
            if (regionData) {
                
                // NOTE forecastJSON may be nil, if no forecast is currently available for this region

                // save the new forecast data
                regionData.forecastJSON = forecastJSON;
                
                // invoke the callback
                dataUpdatedBlock(regionId);                
            }
        }
        success:^()
        {
            DLog(@"finished load forecasts");
#ifndef DEBUG
            [Flurry endTimedEvent:@"LOAD_FORECASTS" withParameters:nil];
#endif            
            successBlock();
        }
        failure:^()
        {
            DLog(@"load forecasts failed");
#ifndef DEBUG
            [Flurry endTimedEvent:@"LOAD_FORECASTS" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
#endif            
            failureBlock();
        }
    ];
}

@end
