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
@synthesize displayName = _displayName;
@synthesize URL = _URL;
@synthesize polygon = _polygon;
@synthesize forecastJSON = _forecastJSON;

- (id) init
{
    return [self initWithRegionId:nil displayName:nil URL:nil polygon:nil];
}

- (id) initWithRegionId:(NSString *)regionId displayName:(NSString *)displayName URL:(NSString *)URL polygon:(MKPolygon *)polygon
{
    self = [super init];
    
    if (self) {
        self.regionId = regionId;
        self.displayName = displayName;
        self.URL = URL;
        self.polygon = polygon;
        self.forecastJSON = nil;
    }
    
    return self;
}

// NOTE all MKOverlay protocol methods are delegated through to the MKPolygon

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    return [self.polygon intersectsMapRect:mapRect];
}

- (MKMapRect) boundingMapRect
{
    return self.polygon.boundingMapRect;
}

- (CLLocationCoordinate2D) coordinate
{
    return self.polygon.coordinate;
}

- (NSString *) title
{
    return self.displayName;
}

- (NSString *) dateStringForDate:(NSDate *) date
{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString * dateString = [dateFormatter stringFromDate:date];
    return dateString; 
}

- (int) aviLevelForDateString:(NSString *) dateString
{
    
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

- (int) aviLevelForToday
{
    NSDate * today = [[NSDate alloc] init];
    return [self aviLevelForDateString:[self dateStringForDate:today]];                        
}

- (int) aviLevelForTomorrow
{
    NSDate * today = [[NSDate alloc] init];
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDate * tomorrow = [today dateByAddingTimeInterval: oneDay];
    return [self aviLevelForDateString:[self dateStringForDate:tomorrow]];
}

- (int) aviLevelForTwoDaysOut
{
    NSDate * today = [[NSDate alloc] init];
    NSTimeInterval twoDays = 2 * 24 * 60 * 60;
    NSDate * twoDaysOut = [today dateByAddingTimeInterval: twoDays];
    return [self aviLevelForDateString:[self dateStringForDate:twoDaysOut]];
}

- (int) aviLevelForMode:(int) mode
{
    
    int aviLevel = AVI_LEVEL_UNKNOWN; 
    
    switch (mode) {
        case MODE_TODAY: 
            aviLevel = [self aviLevelForToday];
            break;
        case MODE_TOMORROW:
            aviLevel = [self aviLevelForTomorrow];
            break;
        case MODE_TWO_DAYS_OUT:
            aviLevel = [self aviLevelForTwoDaysOut];
            break;
        default:
            break;
    }
    
    return aviLevel;
}

@end
