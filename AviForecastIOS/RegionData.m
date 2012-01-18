//
//  RegionData.m
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegionData.h"

@implementation RegionData

@synthesize regionId = _regionId;
@synthesize polygon = _polygon;
@synthesize forecastJSON = _forecastJSON;
@synthesize overlayView = _overlayView;

// NOTE all MKOverlay protocol methods are delegated through to the MKPolygon

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    return [self.polygon intersectsMapRect:mapRect];
}

- (MKMapRect) boundingMapRect {
    return self.polygon.boundingMapRect;
}

- (CLLocationCoordinate2D) coordinate {
    return self.polygon.coordinate;
}

- (int) aviLevelForDateString:(NSString *)dateString {
    
    int aviLevel = AVI_LEVEL_UNKNOWN; 

    if (self.forecastJSON) {
        if ([self.forecastJSON isKindOfClass:[NSArray class]]) {
            
            for (int i = 0; i < ((NSArray *)self.forecastJSON).count; i++) {
                
                // look for a matching date
                if ([dateString isEqualToString:[[self.forecastJSON objectAtIndex:i] valueForKeyPath:@"date"]]) {
                    // found a match, grab the aviLevel
                    aviLevel = [[[self.forecastJSON objectAtIndex:i] valueForKeyPath:@"aviLevel"] intValue];
                    NSLog(@"matching date found; regionId: %@; slot: %i; date: %@; aviLevel: %i", self.regionId, i, dateString, aviLevel);
                    break;
                }
            }
        }
        
    }

    NSLog(@"aviLevel: %i", aviLevel);
    
    return aviLevel;
}

- (NSString *) dateStringForDate:(NSDate *)date {
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString * dateString = [dateFormatter stringFromDate:date];
    return dateString; 
}

@end
