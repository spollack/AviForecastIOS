//
//  Counter.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 2/1/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "Counter.h"

@implementation Counter

@synthesize count = _count;

- (id) init
{
    return [self initWithCount:0];
}

- (id) initWithCount:(int)count
{
    self = [super init];
    
    if (self) {
        _count = count;
    }
    
    return self;
}

- (int) incrementCount
{
    int newCount;
    @synchronized(self) {
        _count += 1;
        newCount = _count; 
    }
    return newCount;
}

- (int) decrementCount
{
    int newCount;
    @synchronized(self) {
        _count -= 1;
        newCount = _count; 
    }
    return newCount;
}

@end
