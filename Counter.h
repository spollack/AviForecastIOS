//
//  Counter.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 2/1/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

@interface Counter : NSObject

@property (nonatomic, readonly) int count;

- (id) initWithCount:(int)count;
- (int) incrementCount;
- (int) decrementCount;

@end
