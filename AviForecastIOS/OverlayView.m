//
//  OverlayView.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 Sebnarware. All rights reserved.
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
        
        // BUGBUG work around an iOS7 bug with CGPathContainsPoint; see:
        // http://stackoverflow.com/questions/19014926/detecting-a-point-in-a-mkpolygon-broke-with-ios7-cgpathcontainspoint
        self.savedPath = CGPathCreateMutable();
        MKMapPoint *polygonPoints = polygon.points;
        for (int p = 0; p < polygon.pointCount; p++)
        {
            MKMapPoint mp = polygonPoints[p];
            if (p == 0) {
                CGPathMoveToPoint(self.savedPath, NULL, mp.x, mp.y);
            } else {
                CGPathAddLineToPoint(self.savedPath, NULL, mp.x, mp.y);
            }
        }
    }
    
    return self;
}

@end
