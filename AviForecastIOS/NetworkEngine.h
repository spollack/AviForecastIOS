//
// manages all network access
//


@class RegionData;

@interface NetworkEngine : NSObject

// callback for returning region data; will be invoked once per region
typedef void (^RegionResponseBlock)(RegionData * regionData);

// callback for returning forecast data; will be invoked once per region
typedef void (^ForecastResponseBlock)(NSString * regionId, id forecastJSON);

- (void) loadRegions:(RegionResponseBlock)dataBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock;
- (void) loadForecasts:(ForecastResponseBlock)dataBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock;

@end
