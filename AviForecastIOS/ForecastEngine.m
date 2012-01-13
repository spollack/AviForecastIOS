//
//  ForecastEngine.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ForecastEngine.h"

@implementation ForecastEngine

- (MKNetworkOperation*) forecastForId:(NSString*) id 
                        onCompletion:(ForecastResponseBlock) completionBlock
                        onError:(MKNKErrorBlock) errorBlock
{
    // NOTE the host is not included here, just the remainder of the URL
    MKNetworkOperation* op = [self operationWithPath:[NSString stringWithFormat:@"/region/%@", id]];
    
    [op onCompletion:^(MKNetworkOperation *completedOperation)
        {
            // NOTE if caching is enabled (currently not), this will get called first with cached data, 
            // and then again with live data if successful
            
            NSLog(@"completed operation; data from cache: %i; response: %@", 
                  [completedOperation isCachedResponse], [completedOperation responseString]);

            // parse out the data
            int aviLevel = [[completedOperation responseString] intValue];
            
            NSLog(@"aviLevel: %i", aviLevel);

            // invoke the callback
            completionBlock(aviLevel);
        }
        onError:^(NSError* error)
        {
            errorBlock(error);
        }
     ];
    
    [self enqueueOperation:op];
    
    return op;
}

@end
