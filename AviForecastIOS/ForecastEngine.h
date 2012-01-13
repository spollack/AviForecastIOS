//
//  ForecastEngine.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForecastEngine : MKNetworkEngine

// callback for returning the data
typedef void (^ForecastResponseBlock)(int aviLevel);
 
- (MKNetworkOperation*) forecastForId:(NSString*) id 
                        onCompletion:(ForecastResponseBlock) completionBlock
                        onError:(MKNKErrorBlock) errorBlock;

@end
