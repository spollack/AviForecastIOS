//
// manages all region and forecast data
//


@class NetworkEngine;

@interface DataManager : NSObject

// callback for data change notifications
typedef void (^DataUpdatedBlock)(NSString * regionId);

@property (strong, nonatomic) NSMutableDictionary * regionsDict;
@property (strong, nonatomic) NetworkEngine * networkEngine;

- (void) loadRegions:(DataUpdatedBlock)dataUpdatedBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock;
- (void) loadForecasts:(DataUpdatedBlock)dataUpdatedBlock success:(SuccessCompletionBlock)successBlock failure:(FailureCompletionBlock)failureBlock;

@end
