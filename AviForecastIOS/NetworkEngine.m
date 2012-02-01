//
//  NetworkEngine.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "NetworkEngine.h"
#import "RegionData.h"

@implementation NetworkEngine

@synthesize networkActivityBlock = _networkActivityBlock;

- (id) init
{
    return [self initWithNetworkActivityBlock:nil]; 
}

- (id) initWithNetworkActivityBlock:(NetworkActivityBlock) networkActivityBlock
{
    self = [super init];
    
    if (self) {
        self.networkActivityBlock = networkActivityBlock;
    }
    
    return self;
}

- (void) loadRegions:(RegionResponseBlock) completionBlock failure:(FailureResponseBlock) failureBlock
{
//    NSURL * url = [NSURL URLWithString:@"http://localhost:5000/v1/regions.json"];
    NSURL * url = [NSURL URLWithString:@"http://aviforecast.herokuapp.com/v1/regions.json"];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    self.networkActivityBlock(TRUE);
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
        {
            NSLog(@"loadRegions network operation success");
            
            int numRegions = 0;
            
            if ([JSON isKindOfClass:[NSArray class]]) {
                
                // parse out each region
                for (int i = 0; i < ((NSArray *)JSON).count; i++) {
                    
                    NSString * regionId = [[JSON objectAtIndex:i] valueForKeyPath:@"regionId"];
                    NSString * displayName = [[JSON objectAtIndex:i] valueForKeyPath:@"displayName"];
                    NSString * URL = [[JSON objectAtIndex:i] valueForKeyPath:@"URL"];
                    NSArray * points = [[JSON objectAtIndex:i] valueForKeyPath:@"points"];

                    if (regionId && displayName && URL && points && [points isKindOfClass:[NSArray class]] && points.count > 3) {
                        
                        int numPts = ((NSArray *)points).count;
                        MKMapPoint pts[numPts];

                        for (int j = 0; j < numPts; j++) {
                            double lat = [[[points objectAtIndex:j] valueForKeyPath:@"lat"] doubleValue];
                            double lon = [[[points objectAtIndex:j] valueForKeyPath:@"lon"] doubleValue];
                            MKMapPoint pt = MKMapPointForCoordinate(CLLocationCoordinate2DMake(lat, lon));
                            pts[j] = pt;
                        }
                        
                        MKPolygon * polygon = [MKPolygon polygonWithPoints:pts count:numPts];
                    
                        RegionData * regionData = [[RegionData alloc] initWithRegionId:regionId displayName:displayName URL:URL polygon:polygon];
                                                
                        numRegions++;
                        NSLog(@"created regionData for regionId: %@", regionId);
                        
                        // invoke the callback for each region read successfully
                        completionBlock(regionData);
                    }
                }
            }
            
            NSLog(@"created %i regions", numRegions);
            
            self.networkActivityBlock(FALSE);
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"loadRegions network operation failure; error: %@", error);
            
            self.networkActivityBlock(FALSE);
            
            failureBlock();
        }];
    
    [operation start];
}

- (void) forecastForRegionId:(NSString *) regionId 
    onCompletion:(ForecastResponseBlock) completionBlock
{
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:5000/v1/region/%@", regionId]];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://aviforecast.herokuapp.com/v1/region/%@", regionId]];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    self.networkActivityBlock(TRUE);

    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
        {
            NSLog(@"forecastForRegionId network operation success; regionId: %@", regionId);
            
            self.networkActivityBlock(FALSE);
                        
            // invoke the callback, returning the new forecast data
            completionBlock(regionId, JSON);
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"forecastForRegionId network operation failure; regionId: %@; error: %@", regionId, error);
            
            self.networkActivityBlock(FALSE);
            
            // invoke the callback, returning nil for the forecast data
            completionBlock(regionId, nil);
        }];
    
    [operation start];
}

@end
