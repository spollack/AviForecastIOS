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
            
            int aviLevel = AVI_LEVEL_UNKNOWN; 
            
            // parse out the data
            if ([JSON isKindOfClass:[NSArray class]]) {
                
                // get the current date
                NSDate * today = [[NSDate alloc] init];
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString * todayString = [dateFormatter stringFromDate:today];

                for (int i = 0; i < ((NSArray *)JSON).count; i++) {

                    // look for a matching date
                    if ([todayString isEqualToString:[[JSON objectAtIndex:i] valueForKeyPath:@"date"]]) {
                        // found a match, grab the aviLevel
                        aviLevel = [[[JSON objectAtIndex:i] valueForKeyPath:@"aviLevel"] intValue];
                        NSLog(@"matching date found; slot: %i; date: %@; aviLevel: %i", i, todayString, aviLevel);
                        break;
                    }
                }
            }
            
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
