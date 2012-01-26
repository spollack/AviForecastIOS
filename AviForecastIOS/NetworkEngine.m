//
//  ForecastEngine.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkEngine.h"
#import "RegionData.h"

@implementation NetworkEngine

- (void) loadRegions:(RegionResponseBlock) completionBlock
{
//    NSURL * url = [NSURL URLWithString:@"http://localhost:5000/v1/regions"];
    NSURL * url = [NSURL URLWithString:@"http://aviforecast.herokuapp.com/v1/regions"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
        {
            NSLog(@"config file network operation success");
            
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
                        
                        NSLog(@"created regionData for regionId: %@", regionId);
                        
                        // invoke the callback for each region read
                        completionBlock(regionData);
                    } else {
                        NSLog(@"invalid data in config file");
                    }
                }
            }
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"config file network operation failure: %@", error);
        }];
    
    [operation start];
}

- (void) forecastForRegionId:(NSString *) regionId 
    onCompletion:(ForecastResponseBlock) completionBlock
{
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:5000/v1/region/%@", regionId]];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://aviforecast.herokuapp.com/v1/region/%@", regionId]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
        {
            NSLog(@"forecast network operation success");
                        
            // invoke the callback, returning the data
            completionBlock(regionId, JSON);
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"forecast network operation failure: %@", error);
        }];
    
    [operation start];
}

@end
