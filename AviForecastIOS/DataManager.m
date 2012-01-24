//
//  DataManager.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "NetworkEngine.h"
#import "RegionData.h"

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

- (void) loadRegions:(DataUpdatedBlock) regionAddedBlock
{
    [self.networkEngine loadRegions:
        ^(RegionData * regionData)
        {
            // add it to our dictionary
            [self.regionsDict setObject:regionData forKey:regionData.regionId];

            // invoke the callback
            regionAddedBlock(regionData.regionId);
        }
     ];
}

- (void) loadForecastForRegionId:(NSString *) regionId onCompletion:(DataUpdatedBlock) forecastUpdatedBlock
{
    [self.networkEngine forecastForRegionId:regionId
        onCompletion:^(NSString * regionId, id forecastJSON)
        {
            RegionData * regionData = [self.regionsDict objectForKey:regionId];
            NSAssert(regionData,@"regionData should not be nil!");

            NSLog(@"onCompletion called; regionId: %@; regionData: %@", regionId, regionData);

            // save the new data
            regionData.forecastJSON = forecastJSON;
            
            // invoke the callback
            forecastUpdatedBlock(regionId);
        }
    ];
}

- (void) loadForecasts:(DataUpdatedBlock) forecastUpdatedBlock
{
    NSArray * allKeys = [self.regionsDict allKeys]; 
    
    for (id key in allKeys) {
        NSString * regionId = (NSString *)key; 
        [self loadForecastForRegionId:regionId onCompletion:forecastUpdatedBlock];
    }
}

@end
