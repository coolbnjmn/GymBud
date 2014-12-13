//
//  LocationFinderVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/11/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "LocationFinderVC.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "GymBudConstants.h"

@interface LocationFinderVC () <UITextFieldDelegate, MLPAutoCompleteTextFieldDataSource, MLPAutoCompleteTextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *places;
@property NSMutableArray *distances;
@property (nonatomic, strong) CLLocationManager *_locationManager;


@end

@implementation LocationFinderVC

@synthesize _locationManager = locationManager;

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
//    [self.mapView setCenterCoordinate:appDelegate.currentLocation.coordinate animated:YES];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Create Event";
    // Do any additional setup after loading the view from its nib.
    self.places = [[NSMutableArray alloc] init];
    self.distances = [[NSMutableArray alloc] init];
    self.locationFinder.autoCompleteDataSource = self;
    self.locationFinder.autoCompleteDelegate = self;
    self.locationFinder.delegate = self;
    self.locationFinder.autoCompleteTableAppearsAsKeyboardAccessory = NO;
    self.locationFinder.autoCompleteTableOriginOffset = CGSizeMake(0, -self.view.bounds.size.height + 45);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if(![self.input isEqualToString:@""] && self.input != nil) {
        self.locationFinder.text = self.input;
        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *currentLocation = appDelegate.currentLocation;
        
        NSDictionary *params = @{@"input" : [self.input stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 @"location" : [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude],
                                 @"sensor" : @"true",
                                 @"key" : kGoogleApiKey};
        
        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];

        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            //        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
            [self.places removeAllObjects];
            for(id description in responseObject[@"predictions"]) {
                [self addDistanceObjectWithLocation:description[@"description"]];
            }
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
         }];
    }
    [self startStandardUpdates];
}

- (void)addDistanceObjectWithLocation:(NSString *)name {
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;

    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    NSDictionary *params2 = @{@"address" : [[name stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                              @"sensor" : @"true",
                              @"key" : kGoogleApiKey};
    [httpSessionManager GET:@"json" parameters:params2 success:^(NSURLSessionDataTask *task2, id responseObject2) {
        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject2);
        NSString *latStr;
        NSString *lngStr;
        for(id object in responseObject2[@"results"]) {
            NSLog(@"%@", object);
            if([object objectForKey:@"geometry"]) {
                latStr = object[@"geometry"][@"location"][@"lat"];
                lngStr = object[@"geometry"][@"location"][@"lng"];
            }
        }
        
        CLLocationDegrees lat = [latStr doubleValue];
        CLLocationDegrees lng = [lngStr doubleValue];
        
        if(lat == 0 || lng == 0) {
            lat = appDelegate.currentLocation.coordinate.latitude;
            lng = appDelegate.currentLocation.coordinate.longitude;
        }
        
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        lat = appDelegate.currentLocation.coordinate.latitude;
        lng = appDelegate.currentLocation.coordinate.longitude;
        
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        
        CLLocationDistance distance = [locA distanceFromLocation:locB];
        
        //Distance in Meters
        
        //1 meter == 100 centimeter
        
        //1 meter == 3.280 feet
        
        double mile_distance = distance * 3.280 / 5280;
        NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
        [mutableDict setObject:[NSNumber numberWithDouble:mile_distance] forKey:@"distance"];
        [mutableDict setObject:name forKey:@"description"];
        [self.places addObject:mutableDict[@"description"]];

        [self.distances addObject:mutableDict[@"distance"]];
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auto Complete Data Source / Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.locationFinder]) {
        if(textField.text.length < 2) {
            return YES;
        }
        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/"];

        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *currentLocation = appDelegate.currentLocation;

        NSDictionary *params = @{@"input" : [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 @"location" : [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude],
                                 @"sensor" : @"true",
                                 @"key" : kGoogleApiKey};

        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            //        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
            [self.places removeAllObjects];
            for(id description in responseObject[@"predictions"]) {
//                [self.places addObject:description[@"description"]];
                [self.tableView reloadData];
                [self addDistanceObjectWithLocation:description[@"description"]];

            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        }];

        return YES;
    } else return YES;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"placeCell"];
    cell.textLabel.text = [self.places objectAtIndex:indexPath.row];
    NSNumber *distance = [self.distances objectAtIndex:indexPath.row];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    NSString *detailLabelText = [fmt stringFromNumber:distance];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %@ miles",detailLabelText];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate performSelector:@selector(didSetLocation:) withObject:[self.places objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
      possibleCompletionsForString:(NSString *)string {
    if([textField isEqual:self.locationFinder]) {
        return self.places;
    } else return [NSArray new];
}
@end
