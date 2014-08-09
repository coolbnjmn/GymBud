//
//  GymBudEventModel.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/7/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface GymBudEventModel : NSObject <MKAnnotation>

//@protocol MKAnnotation <NSObject>

// Center latitude and longitude of the annotion view.
// The implementation of this property must be KVO compliant.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// @optional
// Title and subtitle for use by selection UI.
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *pictureLogo;
@property (nonatomic, readonly, copy) NSString *activity;
// @end

// Other properties:
@property (nonatomic, readonly, strong) PFObject *object;
@property (nonatomic, readonly, strong) PFGeoPoint *geopoint;
@property (nonatomic, readonly, strong) PFUser *organizer;
@property (nonatomic, readonly, strong) NSDate *eventDate;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, assign) NSNumber* isVisible;
@property (nonatomic, readonly) MKPinAnnotationColor pinColor;

// Designated initializer.
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubtitle:(NSString *)subtitle;
- (id)initWithPFObject:(PFObject *)object;
- (BOOL)equalToEvent:(GymBudEventModel *)anEvent;

- (void)setTitleAndSubtitle;

@end
