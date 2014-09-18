//
//  PAWWallViewController.m
//  Anywall
//
//  Created by Christopher Bowns on 1/30/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAWWallViewController.h"
#import "PAWWallPostCreateViewController.h"
#import "UserDetailsViewController.h"
#import "GymBudEventsTVC.h"
#import "EditProfileTVC.h"
#import "MessageInboxTVC.h"
#import "PostCreateTVC.h"
#import "AppDelegate.h"
#import "GymBudConstants.h"
#import "GymBudEventModel.h"

#import <CoreLocation/CoreLocation.h>

// private methods and properties
@interface PAWWallViewController ()

@property (nonatomic, strong) CLLocationManager *_locationManager;
//@property (nonatomic, strong) PAWSearchRadius *searchRadius;
//@property (nonatomic, strong) PAWCircleView *circleView;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) GymBudEventsTVC *wallPostsTableViewController;
@property (nonatomic, assign) BOOL mapPinsPlaced;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

// posts:
@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *allEvents;

- (void)startStandardUpdates;

// CLLocationManagerDelegate methods:
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (void)updatePostsForLocation:(CLLocation *)location withNearbyDistance:(CLLocationAccuracy) filterDistance;

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;

@end

@implementation PAWWallViewController

@synthesize mapView;
@synthesize _locationManager = locationManager;
@synthesize annotations;
@synthesize className;
@synthesize allPosts;
@synthesize allEvents;
@synthesize mapPinsPlaced;
@synthesize mapPannedSinceLocationUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = @"GymBud";
		annotations = [[NSMutableArray alloc] initWithCapacity:10];
		allPosts = [[NSMutableArray alloc] initWithCapacity:10];
        allEvents = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.className = @"Posts";
	self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495f, -122.029095f), MKCoordinateSpanMake(0.008516f, 0.021801f));
	self.mapPannedSinceLocationUpdate = NO;
	[self startStandardUpdates];
    
//    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStyleBordered target:self action:@selector(checkInButtonTouchHandler:)];
//    self.navigationItem.leftBarButtonItem = checkInButton;
    
    UIImage *buttonImage = [UIImage imageNamed:@"mapTableToggle2.png"];
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    UIBarButtonItem *mapToTableViewButton = [[UIBarButtonItem alloc] initWithImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] action:@selector(toggleMapTable:)];
    self.navigationItem.rightBarButtonItem = mapToTableViewButton;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    
    self.navigationItem.title = @"Local GymBuds";
    self.navigationItem.hidesBackButton = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:@"LocationChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:@"CreatePostNotification" object:nil];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
	[locationManager startUpdatingLocation];
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[locationManager stopUpdatingLocation];
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PostCreatedNotification" object:nil];

	self.mapPinsPlaced = NO; // reset this for the next time we show the map.
}

#pragma mark - NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note {
	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	// If they panned the map since our last location update, don't recenter it.
	if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their location at 2x filterDistance
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);

		[mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = NO;
	} else {
		// Just zoom to the new search radius (or maybe don't even do that?)
		MKCoordinateRegion currentRegion = mapView.region;
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, appDelegate.filterDistance * 2.0f, appDelegate.filterDistance * 2.0f);

		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
		[mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	}
}


#pragma mark - CLLocationManagerDelegate methods and helpers

- (void)startStandardUpdates {
	if (nil == locationManager) {
		locationManager = [[CLLocationManager alloc] init];
	}

	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;

	// Set a movement threshold for new events.
	locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;

	[locationManager startUpdatingLocation];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	CLLocation *currentLocation = locationManager.location;
	if (currentLocation) {
		appDelegate.currentLocation = currentLocation;
	}
//    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    [self.mapView setCenterCoordinate:appDelegate.currentLocation.coordinate animated:YES];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			// Re-enable the post button if it was disabled before.
			self.navigationItem.rightBarButtonItem.enabled = YES;
			[locationManager startUpdatingLocation];
            [locationManager requestWhenInUseAuthorization];
            [self startStandardUpdates];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
			{{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GymBud can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for GymBud to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
				[alertView show];
				// Disable the post button.
				self.navigationItem.rightBarButtonItem.enabled = NO;
			}}
			break;
		case kCLAuthorizationStatusNotDetermined:
            [manager requestAlwaysAuthorization];
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	NSLog(@"%s", __PRETTY_FUNCTION__);

	AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);

	if (error.code == kCLErrorDenied) {
		[locationManager stopUpdatingLocation];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:[error description]
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	}
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	MKOverlayView *result = nil;
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	return result;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	// Let the system handle user location annotations.
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}

	static NSString *pinIdentifier = @"CustomPinAnnotation";

    NSLog(@"view for annotation");
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[PAWPost class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:pinIdentifier];
        }
        else {
            pinView.annotation = annotation;
        }

        UIImage *tmp = [UIImage imageNamed:[kGymBudActivityMapIconMapping objectForKey:((PAWPost *)annotation).activity]];

        CGSize destinationSize = CGSizeMake(32, 52);
        UIGraphicsBeginImageContext(destinationSize);
        [tmp drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        pinView.image = newImage;
        pinView.canShowCallout = YES;
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[((PAWPost *) annotation) pictureURL]] scale:6]];
        pinView.rightCalloutAccessoryView = infoButton;
        return pinView;
    } else if([annotation isKindOfClass:[GymBudEventModel class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:pinIdentifier];
        }
        else {
            pinView.annotation = annotation;
        }
        
        UIImage *tmp = [UIImage imageNamed:[kGymBudActivityMapIconMapping objectForKey:((GymBudEventModel *)annotation).activity]];
        
        CGSize destinationSize = CGSizeMake(32, 52);
        UIGraphicsBeginImageContext(destinationSize);
        [tmp drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        pinView.image = newImage;
        pinView.canShowCallout = YES;
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        UIImage *leftImage = [UIImage imageNamed:((GymBudEventModel *)annotation).pictureLogo];
        CGSize destinationSizeLogo = CGSizeMake(40, 40);
        UIGraphicsBeginImageContext(destinationSizeLogo);
        [leftImage drawInRect:CGRectMake(0,0,destinationSizeLogo.width,destinationSizeLogo.height)];
        UIImage *finalLeftImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        pinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:finalLeftImage];
        pinView.rightCalloutAccessoryView = infoButton;
        return pinView;
    }
    
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"annotation view callout accessory control tapped");
    UserDetailsViewController *controller = [[UserDetailsViewController alloc] initWithNibName:nil
                                                                                bundle:nil];
    controller.annotation = [view annotation];
    [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	id<MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[PAWPost class]]) {
		PAWPost *post = [view annotation];
	} else if ([annotation isKindOfClass:[MKUserLocation class]]) {
		// Center the map on the user's current location:
		AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance * 2, appDelegate.filterDistance * 2);

		[self.mapView setRegion:newRegion animated:YES];
		self.mapPannedSinceLocationUpdate = NO;
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	id<MKAnnotation> annotation = [view annotation];
	if ([annotation isKindOfClass:[PAWPost class]]) {
		PAWPost *post = [view annotation];
	}
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	self.mapPannedSinceLocationUpdate = YES;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    NSLog(@"didAddAnnotationViews");
    MKAnnotationView *aV;
    for (aV in views) {
        if([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
        
    }
}

#pragma mark - Fetch map pins
- (void)queryForAllEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    
    [query whereKey:@"isVisible" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in events geo query!"); // todo why is this ever happening?
        } else {
            // We need to make new post objects from objects,
            // and update allPosts and the map to reflect this new array.
            // But we don't want to remove all annotations from the mapview blindly,
            // so let's do some work to figure out what's new and what needs removing.
            NSLog(@"event geo query was successful!");
            // 1. Find genuinely new posts:
            NSMutableArray *newEvents = [[NSMutableArray alloc] initWithCapacity:1000];
            // (Cache the objects we make for the search in step 2:)
            NSMutableArray *allNewEvents = [[NSMutableArray alloc] initWithCapacity:1000];
            for (PFObject *object in objects) {
                GymBudEventModel *newEvent = [[GymBudEventModel alloc] initWithPFObject:object];
                NSDate *finalTime = [newEvent.eventDate  dateByAddingTimeInterval:[newEvent.duration integerValue]*60];
                if([[NSDate date] compare:finalTime] == NSOrderedDescending) {
                    // if NSDate date is later than newEvent.eventDate, go into this if
                    NSLog(@"%@", newEvent.eventDate);
                    NSLog(@"%@", [NSDate date]);
                    NSLog(@"NSOrderedDescending");
                    [object setObject:[NSNumber numberWithBool:NO] forKey:@"isVisible"];
                    [object saveInBackground];
                    continue;
                }
                [allNewEvents addObject:newEvent];
                BOOL found = NO;
                for (GymBudEventModel *currentEvent in allEvents) {
                    if ([newEvent equalToEvent:currentEvent]) {
                        found = YES;
                    }
                }
                if (!found) {
                    [newEvents addObject:newEvent];
                }
            }
            // newEvents now contains our new objects.
            
            // 2. Find posts in allEvents that didn't make the cut.
            NSMutableArray *eventsToRemove = [[NSMutableArray alloc] initWithCapacity:1000];
            for (GymBudEventModel *currentEvent in allEvents) {
                BOOL found = NO;
                // Use our object cache from the first loop to save some work.
                for (GymBudEventModel *allNewEvent in allNewEvents) {
                    if ([currentEvent equalToEvent:allNewEvent]) {
                        found = YES;
                    }
                }
                if (!found) {
                    [eventsToRemove addObject:currentEvent];
                }
            }
            // eventsToRemove has objects that didn't come in with our new results.
            
            // 3. Configure our new posts; these are about to go onto the map.
            for (GymBudEventModel *newEvent in newEvents) {
                // if this post is outside the filter distance, don't show the regular callout.
                [newEvent setTitleAndSubtitle];
                // Animate all pins after the initial load:
                newEvent.animatesDrop = mapPinsPlaced;
            }
            
            // At this point, newAllPosts contains a new list of post objects.
            // We should add everything in newPosts to the map, remove everything in postsToRemove,
            // and add newPosts to allPosts.
            [mapView removeAnnotations:eventsToRemove];
            NSLog(@"events to add: %@", newEvents);
            [mapView addAnnotations:newEvents];
            [allEvents addObjectsFromArray:newEvents];
            [allEvents removeObjectsInArray:eventsToRemove];
            
            self.mapPinsPlaced = YES;
        }
    }];
    
}
- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    NSLog(@"query for all posts near location");
	PFQuery *query = [PFQuery queryWithClassName:self.className];

	if (currentLocation == nil) {
		NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
	}

	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.allPosts count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
    // Query for posts sort of kind of near our current location.
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    [query whereKey:@"location" nearGeoPoint:point withinKilometers:100];
    [query includeKey:@"user"];
    query.limit = 1000;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in geo query!"); // todo why is this ever happening?
        } else {
            // We need to make new post objects from objects,
            // and update allPosts and the map to reflect this new array.
            // But we don't want to remove all annotations from the mapview blindly,
            // so let's do some work to figure out what's new and what needs removing.
            NSLog(@"geo query was successful!");
            // 1. Find genuinely new posts:
            NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:1000];
            // (Cache the objects we make for the search in step 2:)
            NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:1000];
            for (PFObject *object in objects) {
                PAWPost *newPost = [[PAWPost alloc] initWithPFObject:object];
                [allNewPosts addObject:newPost];
                BOOL found = NO;
                for (PAWPost *currentPost in allPosts) {
                    if ([newPost equalToPost:currentPost]) {
                        found = YES;
                    }
                }
                if (!found) {
                    [newPosts addObject:newPost];
                }
            }
            // newPosts now contains our new objects.
            
            // 2. Find posts in allPosts that didn't make the cut.
            NSMutableArray *postsToRemove = [[NSMutableArray alloc] initWithCapacity:1000];
            for (PAWPost *currentPost in allPosts) {
                BOOL found = NO;
                // Use our object cache from the first loop to save some work.
                for (PAWPost *allNewPost in allNewPosts) {
                    if ([currentPost equalToPost:allNewPost]) {
                        found = YES;
                    }
                }
                if (!found) {
                    [postsToRemove addObject:currentPost];
                }
            }
            // postsToRemove has objects that didn't come in with our new results.
            
            // 3. Configure our new posts; these are about to go onto the map.
            for (PAWPost *newPost in newPosts) {
                CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newPost.coordinate.latitude longitude:newPost.coordinate.longitude];
                // if this post is outside the filter distance, don't show the regular callout.
                CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
                [newPost setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
                // Animate all pins after the initial load:
                newPost.animatesDrop = mapPinsPlaced;
            }
            
            // At this point, newAllPosts contains a new list of post objects.
            // We should add everything in newPosts to the map, remove everything in postsToRemove,
            // and add newPosts to allPosts.
            [mapView removeAnnotations:postsToRemove];
            NSLog(@"posts to add: %@", newPosts);
            [mapView addAnnotations:newPosts];
            [allPosts addObjectsFromArray:newPosts];
            [allPosts removeObjectsInArray:postsToRemove];
            
            self.mapPinsPlaced = YES;
        }
    }];

}

// When we update the search filter distance, we need to update our pins' titles to match.
- (void)updatePostsForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
//    for (PAWPost *post in allPosts) {
//        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:post.coordinate.latitude longitude:post.coordinate.longitude];
//        // if this post is outside the filter distance, don't show the regular callout.
//        CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
//        if (distanceFromCurrent > nearbyDistance) { // Outside search radius
//            [post setTitleAndSubtitleOutsideDistance:YES];
//            [mapView viewForAnnotation:post];
//            [(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
//        } else {
//            [post setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
//            [mapView viewForAnnotation:post];
//            [(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
//        }
//    }
}


- (void)checkInButtonTouchHandler:(id)sender {
    NSLog(@"check in button being pressed");
    
//    [self.navigationController pushViewController:[[PAWWallPostCreateViewController alloc] init] animated:YES];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PostCreateTVC" bundle:nil];
    PostCreateTVC *vc = [sb instantiateViewControllerWithIdentifier:@"PostCreate"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)locationDidChange:(NSNotification *)note {
    NSLog(@"location Did change in view controller");
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // Update the map with new pins:
    [self queryForAllEvents];
//    [self queryForAllPostsNearLocation:appDelegate.currentLocation
//                    withNearbyDistance:appDelegate.filterDistance];
    // And update the existing pins to reflect any changes in filter distance:
    [self updatePostsForLocation:appDelegate.currentLocation
              withNearbyDistance:appDelegate.filterDistance];
}

- (void)postWasCreated:(NSNotification *)note {
    NSLog(@"Post Was Created!");
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [self queryForAllPostsNearLocation:appDelegate.currentLocation
                    withNearbyDistance:appDelegate.filterDistance];

}

@end
