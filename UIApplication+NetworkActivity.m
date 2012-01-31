//
//  UIApplication+NetworkActivity.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/30/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "UIApplication+NetworkActivity.h"

@implementation UIApplication (NetworkActivity)

-(void) toggleNetworkActivityIndicatorVisible:(BOOL)visible
{
    static int activityCount = 0;
    @synchronized (self) {
        visible ? activityCount++ : activityCount--;
        self.networkActivityIndicatorVisible = activityCount > 0;
    }
}

@end