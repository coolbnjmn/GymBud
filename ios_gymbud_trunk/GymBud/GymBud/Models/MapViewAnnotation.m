//
//  MapViewAnnotation.m
//  GymBud
//
//  Created by Hashim Shafique on 12/17/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    _title = title;
    _coordinate = coordinate;
    return self;
}
@end
