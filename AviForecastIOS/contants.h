//
//  contants.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/13/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

//
// application-wide constants
//

#define AVI_LEVEL_UNKNOWN 0
#define AVI_LEVEL_LOW 1
#define AVI_LEVEL_MODERATE 2
#define AVI_LEVEL_CONSIDERABLE 3
#define AVI_LEVEL_HIGH 4
#define AVI_LEVEL_EXTREME 5

#define MODE_TODAY 0
#define MODE_TOMORROW 1
#define MODE_TWO_DAYS_OUT 2


//
// callbacks for completion, success or failure
//

typedef void (^SuccessCompletionBlock)();
typedef void (^FailureCompletionBlock)();
