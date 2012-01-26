//
//  OverlayView.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

@synthesize regionId = _regionId;

- (id) init
{
    return [self initWithPolygon:nil regionId:nil];
}

- (id) initWithPolygon:(MKPolygon *)polygon regionId:(NSString *)regionId
{
    self = [super initWithPolygon:polygon];
    
    if (self) {
        self.regionId = regionId;
    }
    
    return self;
}

@end
