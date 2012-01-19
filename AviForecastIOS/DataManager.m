//
//  DataManager.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "ForecastEngine.h"
#import "RegionData.h"

@implementation DataManager

@synthesize regionsDict = _regionsDict;
@synthesize forecastEngine = _forecastEngine;

- (id) init
{
    self = [super init];
    
    if (self) {
        self.regionsDict = [NSMutableDictionary dictionary];
        self.forecastEngine = [[ForecastEngine alloc] init];
    }
    
    return self;
}

- (void) refreshForecasts:(DataUpdatedBlock) dataUpdatedBlock
{
    NSArray * allKeys = [self.regionsDict allKeys]; 
    
    for (id key in allKeys) {
        
        NSString * regionId = (NSString *)key; 
        
        [self.forecastEngine forecastForRegionId:regionId
            onCompletion:^(NSString * regionId, id forecastJSON)
            {
                RegionData * regionData = [self.regionsDict objectForKey:regionId];
                NSAssert(regionData,@"regionData should not be nil!");
                
                NSLog(@"onCompletion called; regionId: %@; regionData: %@", regionId, regionData);

                // save the new data
                regionData.forecastJSON = forecastJSON; 

                // invoke the callback
                dataUpdatedBlock(regionId);
            }
        ];
    }
}

@end
