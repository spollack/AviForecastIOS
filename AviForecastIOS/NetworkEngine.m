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

- (id) init
{
    self = [super init];
    
    if (self) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    
    return self;
}

- (void) loadRegions:(RegionResponseBlock)dataBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock
{
//    NSURL * url = [NSURL URLWithString:@"http://localhost:5000/v1/regions.json"];
    NSURL * url = [NSURL URLWithString:@"http://aviforecast.herokuapp.com/v1/regions.json"];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
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
                        dataBlock(regionData);
                    }
                }
            }
            
            NSLog(@"created %i regions", numRegions);
            
            successBlock();
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"loadRegions network operation failure; error: %@", error);
            
            failureBlock();
        }];
    
    [operation start];
}

- (void) loadForecasts:(ForecastResponseBlock)dataBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock
{
//    NSURL * url = [NSURL URLWithString:@"http://localhost:5000/v1/forecasts.json"];
    NSURL * url = [NSURL URLWithString:@"http://aviforecast.herokuapp.com/v1/forecasts.json"];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
        {
            NSLog(@"loadForecasts network operation success");

            int numRegions = 0;
            
            if ([JSON isKindOfClass:[NSArray class]]) {
                
                // parse out each region
                for (int i = 0; i < ((NSArray *)JSON).count; i++) {
                    
                    NSString * regionId = [[JSON objectAtIndex:i] valueForKeyPath:@"regionId"];
                    NSArray * forecast = [[JSON objectAtIndex:i] valueForKeyPath:@"forecast"];
                    
                    if (regionId && forecast && [forecast isKindOfClass:[NSArray class]]) {
                                                
                        numRegions++;
                        NSLog(@"loaded forecast for regionId: %@", regionId);
                        
                        // invoke the callback for each region read successfully
                        dataBlock(regionId, forecast);
                    }
                }
            }
            
            NSLog(@"read forecasts for %i regions", numRegions);
            
            successBlock();
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"loadForecasts network operation failure; error: %@", error);
            
            failureBlock();
        }];
    
    [operation start];
}

@end
