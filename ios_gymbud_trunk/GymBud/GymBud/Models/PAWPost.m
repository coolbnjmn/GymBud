//
//  PAWPost.m
//  Anywall
//
//  Created by Christopher Bowns on 2/8/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAWPost.h"
#import "AppDelegate.h"

@interface PAWPost ()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSURL *pictureURL;
@property (nonatomic, copy) NSString *activity;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation PAWPost

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle {
	self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.subtitle = aSubtitle;
		self.animatesDrop = NO;
	}
	return self;
}

- (id)initWithPFObject:(PFObject *)anObject {
	self.object = anObject;
	self.geopoint = [anObject objectForKey:@"location"];
	self.user = [anObject objectForKey:@"user"];

    self.activity = [anObject objectForKey:@"activity"];
    [self.user fetchIfNeeded];
	[anObject fetchIfNeeded]; 
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	NSString *aTitle = [anObject objectForKey:@"text"];
	NSString *aSubtitle = [[anObject objectForKey:@"user"] objectForKey:@"username"];

	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle];
}

- (BOOL)equalToPost:(PAWPost *)aPost {
	if (aPost == nil) {
		return NO;
	}

	if (aPost.object && self.object) {
		// We have a PFObject inside the PAWPost, use that instead.
		if ([aPost.object.objectId compare:self.object.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:

		if ([aPost.title compare:self.title] != NSOrderedSame ||
			[aPost.subtitle compare:self.subtitle] != NSOrderedSame ||
			aPost.coordinate.latitude != self.coordinate.latitude ||
			aPost.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}

		return YES;
	}
}

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
    self.title = [self.object objectForKey:@"text"];
    
    NSString *name;
    if([[[self.object objectForKey:@"user"] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
        name = [[[self.object objectForKey:@"user"] objectForKey:@"gymbudProfile"] objectForKey:@"name"];
    } else {
        name = [[[self.object objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"name"];
    }
    self.subtitle = name;
    self.pinColor = MKPinAnnotationColorRed;
    self.pictureURL = [NSURL URLWithString:[[[self.object objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"pictureURL"]];
    self.activity = [self.object objectForKey:@"activity"];
}

@end
