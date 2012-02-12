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
#import "FlurryAnalytics.h"


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
    NSLog(@"starting initial data load");
    [FlurryAnalytics logEvent:@"INITIAL_DATA_LOAD" 
               withParameters:nil 
                        timed:YES];
    NSLog(@"starting load regions");
    [FlurryAnalytics logEvent:@"LOAD_REGIONS" 
               withParameters:nil 
                        timed:YES];

    [self.networkEngine loadRegions:
        ^(RegionData * regionData)
        {
            // add it to our dictionary
            [self.regionsDict setObject:regionData forKey:regionData.regionId];
        }
        success:^()
        {
            NSLog(@"finished load regions");
            [FlurryAnalytics endTimedEvent:@"LOAD_REGIONS" withParameters:nil];
            
            // now that we have the regions, load the forecasts
            [self loadForecasts:dataUpdatedBlock
                success:^()
                {
                    NSLog(@"finished initial data load");
                    [FlurryAnalytics endTimedEvent:@"INITIAL_DATA_LOAD" withParameters:nil];
                }
                failure:^()
                {
                    NSLog(@"initial data load failed");
                    [FlurryAnalytics endTimedEvent:@"INITIAL_DATA_LOAD" 
                                    withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
                }
            ];
            
            successBlock();
        }
        failure:^()
        {
            NSLog(@"load regions failed");
            [FlurryAnalytics endTimedEvent:@"LOAD_REGIONS" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
            NSLog(@"initial data load failed");
            [FlurryAnalytics endTimedEvent:@"INITIAL_DATA_LOAD" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];

            failureBlock();
        }
    ];
}

- (void) loadForecasts:(DataUpdatedBlock)dataUpdatedBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock
{
    // start timed event
    NSLog(@"starting load forecasts");
    [FlurryAnalytics logEvent:@"LOAD_FORECASTS" 
               withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",self.regionsDict.count], @"region count", nil] 
                        timed:YES];
    
    [self.networkEngine loadForecasts:
        ^(NSString * regionId, id forecastJSON)
        {
            RegionData * regionData = [self.regionsDict objectForKey:regionId];
            
            // NOTE regionData could be null, if we are serving forecasts for regions that this client isn't aware of yet
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
            NSLog(@"finished load forecasts");
            [FlurryAnalytics endTimedEvent:@"LOAD_FORECASTS" withParameters:nil];
            
            successBlock();
        }
        failure:^()
        {
            NSLog(@"load forecasts failed");
            [FlurryAnalytics endTimedEvent:@"LOAD_FORECASTS" 
                            withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"failed", nil]];
            
            failureBlock();
        }
    ];
}

@end
