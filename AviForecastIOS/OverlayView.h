//
// overlay view for the map
//


@interface OverlayView : MKPolygonView

@property (strong, nonatomic) NSString * regionId;
@property CGMutablePathRef savedPath;

- (id) initWithPolygon:(MKPolygon *)polygon regionId:(NSString *)regionId;

@end
