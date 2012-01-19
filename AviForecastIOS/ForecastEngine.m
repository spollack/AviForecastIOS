//
//  ForecastEngine.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ForecastEngine.h"

@implementation ForecastEngine

- (void) forecastForRegionId:(NSString *) regionId 
    onCompletion:(ForecastResponseBlock) completionBlock
{
    // BUGBUG returned cached data if already loaded; otherwise do the networking dance below...
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://falling-lightning-8605.herokuapp.com/version/1/region/%@", regionId]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];

    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
        success:^(NSURLRequest * request, NSHTTPURLResponse * response, id JSON)
        {
            NSLog(@"network operation success");
                        
            // invoke the callback, returning the data
            completionBlock(regionId, JSON);
        }
        failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON)
        {
            NSLog(@"network operation failure: %@", error);
            
            // invoke the callback, specifying no information
            completionBlock(regionId, nil);
        }];
    
    [operation start];
}

@end
