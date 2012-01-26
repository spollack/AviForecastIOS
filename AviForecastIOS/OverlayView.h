//
//  OverlayView.h
//  AviForecastIOS
//
//  Created by Seth Pollack on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface OverlayView : MKPolygonView

@property (strong, nonatomic) NSString * regionId;

- (id) initWithPolygon:(MKPolygon *)polygon regionId:(NSString *)regionId;

@end
