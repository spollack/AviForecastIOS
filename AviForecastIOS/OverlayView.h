//
//  OverlayView.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 SEBNARWARE. All rights reserved.
//

//
// overlay view for the map
//


@interface OverlayView : MKPolygonView

@property (strong, nonatomic) NSString * regionId;

- (id) initWithPolygon:(MKPolygon *)polygon regionId:(NSString *)regionId;

@end
