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

- (void) loadRegions
{
    // BUGBUG temp hardcoded
    
    NSString * regionId = @"nwac_6";
    
    MKMapPoint p1 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.476, -121.722));
    MKMapPoint p2 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.391, -121.476));
    MKMapPoint p3 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.709, -121.130));
    MKMapPoint p4 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(47.861, -121.795));
    MKMapPoint pts[4] = {p1,p2,p3,p4};
    MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:4];
    
    RegionData * regionData = [[RegionData alloc] initWithRegionId:regionId andPolygon:polygon];
    
    // add it to our dictionary
    [self.regionsDict setObject:regionData forKey:regionId];
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
