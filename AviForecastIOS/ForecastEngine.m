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
        success:^(NSURLRequest * request, NSHTTPURLResponse *response, id JSON)
        {
            NSLog(@"network operation success");
            
            // parse out the data
            if ([JSON isKindOfClass:[NSArray class]]) {
                int count = ((NSArray *)JSON).count; 
                NSLog(@"array count: %i", count);
                for (int i = 0; i < count; i++) {
                    NSLog(@"slot: %i; date: %@; aviLevel: %i", i, [[JSON objectAtIndex:i] valueForKeyPath:@"date"], [[[JSON objectAtIndex:i] valueForKeyPath:@"aviLevel"] intValue]);
                }
            }
            
            // BUBUG error handling!!!
            
            int aviLevel = [[[JSON objectAtIndex:0] valueForKeyPath:@"aviLevel"] intValue];
            NSLog(@"aviLevel: %i", aviLevel);
            
            // invoke the callback
            completionBlock(aviLevel);
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            NSLog(@"network operation failure: %@", error);
            
            // invoke the callback, specifying no information
            // BUGBUG clean this up
            completionBlock(0);
        }];
    
    [operation start];
}

@end
