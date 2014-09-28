//
// contains data for a single region; also acts as an overlay (data, not view) 
//


@interface RegionData : NSObject <MKOverlay>

@property (strong, nonatomic) NSString * regionId;
@property (strong, nonatomic) NSString * displayName;
@property (strong, nonatomic) NSString * URL;
@property (strong, nonatomic) MKPolygon * polygon;
@property (strong, nonatomic) id forecastJSON;
@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id) initWithRegionId:(NSString *)regionId displayName:(NSString *)displayName URL:(NSString *)URL polygon:(MKPolygon *)polygon;
- (int) aviLevelForMode:(int) mode;

@end
