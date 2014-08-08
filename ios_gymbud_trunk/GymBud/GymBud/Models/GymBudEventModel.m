//
//  GymBudEventModel.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/7/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudEventModel.h"
#import "GymBudConstants.h"

@interface GymBudEventModel ()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *pictureLogo;
@property (nonatomic, copy) NSString *activity;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *organizer;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation GymBudEventModel

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.subtitle = subtitle;
        self.animatesDrop = NO;
    }
    return self;
}
- (id)initWithPFObject:(PFObject *)anObject {
    self.object = anObject;
    self.geopoint = [anObject objectForKey:@"location"];
    self.organizer = [anObject objectForKey:@"organizer"];
    
    self.activity = [anObject objectForKey:@"activity"];
    [anObject fetchIfNeeded];
    CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
    NSString *aTitle = [anObject objectForKey:@"activity"];
    NSDate *time = [anObject objectForKey:@"time"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    NSString *aSubtitle = [NSString stringWithFormat:@"Tap to join this Event! @ %@", [formatter stringFromDate:time]];
    
    return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle];
}
- (BOOL)equalToEvent:(GymBudEventModel *)anEvent {
    if (anEvent == nil) {
        return NO;
    }
    
    if (anEvent.object && self.object) {
        // We have a PFObject inside the PAWPost, use that instead.
        if ([anEvent.object.objectId compare:self.object.objectId] != NSOrderedSame) {
            return NO;
        }
        return YES;
    } else {
        // Fallback code:
        
        if ([anEvent.title compare:self.title] != NSOrderedSame ||
            [anEvent.subtitle compare:self.subtitle] != NSOrderedSame ||
            anEvent.coordinate.latitude != self.coordinate.latitude ||
            anEvent.coordinate.longitude != self.coordinate.longitude ) {
            return NO;
        }
        
        return YES;
    }
}

- (void)setTitleAndSubtitle {
    self.title = [self.object objectForKey:@"activity"];
    NSDate *time = [self.object objectForKey:@"time"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    self.subtitle = [NSString stringWithFormat:@"Tap to join this Event! @ %@", [formatter stringFromDate:time]];
    self.pinColor = MKPinAnnotationColorRed;
    self.pictureLogo = [kGymBudActivityIconMapping objectForKey:[self.object objectForKey:@"activity"]];
    self.activity = [self.object objectForKey:@"activity"];
}
@end
