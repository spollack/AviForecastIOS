//
//  RegionData.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface RegionData : NSObject <MKOverlay>

@property (strong, nonatomic) NSString * regionId;
@property (strong, nonatomic) NSString * displayName;
@property (strong, nonatomic) NSString * URL;
@property (strong, nonatomic) MKPolygon * polygon;
@property (strong, nonatomic) id forecastJSON;
@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString * title;

- (id) initWithRegionId:(NSString *)regionId displayName:(NSString *)displayName URL:(NSString *)URL polygon:(MKPolygon *)polygon;
- (int) aviLevelForMode:(int) mode;

@end
