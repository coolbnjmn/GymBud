//
//  GymBudEventsTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudEventsTVC.h"
#import "GymBudEventModel.h"
#import "UserDetailsViewController.h"
#import "AppDelegate.h"
#import "GymBudConstants.h"
#import "NSDate+Utilities.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "GBEventsFilterViewController.h"
#import "Mixpanel.h"
#import <CoreLocation/CoreLocation.h>


#define kCellHeight 100

@interface GymBudEventsTVC () <CLLocationManagerDelegate>

@property NSString *reuseId;
@property MBProgressHUD *HUD;
@property (strong,nonatomic) UIViewController *modal;
@property (strong, nonatomic) UIView *opaqueView;
@property (nonatomic, strong) NSArray *activityFilters;
@property (nonatomic, strong) CLLocationManager *locationManager;


@end

@implementation GymBudEventsTVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationChangeNotification" object:nil];
}

- (void)viewDidLoad
{
    [self startStandardUpdates];

    [super viewDidLoad];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    
    self.reuseId = @"eventCell";
    self.parseClassName = @"Event";
//    [self.tableView registerNib:[UINib nibWithNibName:@"GymBudEventsCell" bundle:nil] forCellReuseIdentifier:self.reuseId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:@"LocationChangeNotification" object:nil];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.navigationItem.title = @"Events Nearby";
}

- (void) viewDidDisappear:(BOOL)animated {
    self.activityFilters = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.HUD hide:YES];
    NSLog(@"objectsDidLoad GymBudEventsTVC 1");
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    // Query for posts near our current location.
    
    // Get our current location:
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;
    
    // And set the query to look by location
    NSLog(@"querying now");
    if(currentLocation != nil) {
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
        [query whereKey:@"location" nearGeoPoint:point withinKilometers:100];
    }
    [query includeKey:@"organizer"];
    [query whereKey:@"isVisible" equalTo:[NSNumber numberWithBool:YES]];
//    [query orderByAscending:@"time"];
    if(self.activityFilter != nil) {
        [query whereKey:@"activity" equalTo:self.activityFilter];
    }
    if(self.timeFiler != nil) {
        //NSDate *newDate = [oldDate dateByAddingTimeInterval:-60*15];
        [query whereKey:@"time" greaterThanOrEqualTo:[self.timeFiler dateByAddingTimeInterval:-5*60]];
    }
    
    if(self.activityFilters != nil) {
        [query whereKey:@"activity" containedIn:self.activityFilters];
    }
    
    if(self.additionalFilter != nil && ![self.additionalFilter isEqualToString:@""]) {
        [query whereKey:@"additional" equalTo:self.additionalFilter];
    }
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kLoadingAnimationWidth, kLoadingAnimationHeight)];
    imageView.image = [UIImage imageNamed:kLoadingImageFirst];
    //Add more images which will be used for the animation
    imageView.animationImages = kLoadingImagesArray;
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    imageView.animationDuration = kLoadingAnimationDuration;
    [imageView startAnimating];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.color = [UIColor clearColor];
    
    [self.HUD show:YES];
    for (UIView *subview in self.view.subviews)
    {
        if ([subview class] == NSClassFromString(@"PFLoadingView"))
        {
            [subview removeFromSuperview];
        }
    }
    [self setLoadingViewEnabled:NO];
    return query;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    NSLog(@"Object is %@", object);
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"joined"
                                                                 forIndexPath:indexPath];
    
    PFFile *theImage = [object objectForKey:@"organizer"][@"gymbudProfile"][@"profilePicture"];
    
    __weak UITableViewCell *weakCell = cell;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        NSLog(@"+++++++++ Loading image view with real data ++++++++");
        UIImageView *pict = (UIImageView*) [cell viewWithTag:10];
        pict.image = [UIImage imageWithData:data];
        [weakCell setNeedsLayout];
        pict.layer.cornerRadius = 30.0f;
        pict.layer.masksToBounds = YES;
        CGSize itemSize = CGSizeMake(60, 60);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [pict.image drawInRect:imageRect];
        pict.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    
    nameLabel.font = [UIFont fontWithName:@"MagistralATT" size:18];
    dateLabel.font = [UIFont fontWithName:@"MagistralATT" size:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textColor = [UIColor whiteColor];
    dateLabel.textColor = [UIColor whiteColor];
    
    nameLabel.text = [NSString stringWithFormat:@"Event Organizer: %@",[object objectForKey:@"organizer"][@"gymbudProfile"][@"name"]];
    
    NSDate *eventStartTime = [object objectForKey:@"time"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSString *dateString = [format stringFromDate:eventStartTime];
    
    dateLabel.text = [NSString stringWithFormat:@"Event Time: %@", dateString];
    cell.backgroundColor = kGymBudLightBlue;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.numberOfLines = 1;
    
    [nameLabel sizeToFit];
    
    NSArray *subLogoIndices = [object objectForKey:@"detailLogoIndices"];
    int subLogoIndex = 0;
    for(NSNumber *index in subLogoIndices) {
        if(subLogoIndex == 0) {
            
            UIImageView *imv = (UIImageView*) [cell viewWithTag:4];
            imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
            [cell.contentView addSubview:imv];
        } else if(subLogoIndex == 1) {
            UIImageView *imv = (UIImageView*) [cell viewWithTag:5];
            imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
            [cell.contentView addSubview:imv];
        } else if(subLogoIndex == 2) {
            UIImageView *imv = (UIImageView*) [cell viewWithTag:6];
            imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
            [cell.contentView addSubview:imv];
        } else {
            UIImageView *imv = (UIImageView*) [cell viewWithTag:7];
            imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
            [cell.contentView addSubview:imv];
        }
        subLogoIndex++;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//    UserDetailsViewController *controller = [[UserDetailsViewController alloc] initWithNibName:nil
//                                                                                        bundle:nil];
//    GymBudEventsCell *cell = (GymBudEventsCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
//    [query includeKey:@"organizer"];
//    [query whereKey:@"objectId" equalTo:[[self.objects objectAtIndex:indexPath.row] objectId]];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
//        if(self.navigationController.topViewController == self) {
////            GymBudEventModel *post = [[GymBudEventModel alloc] initWithPFObject:[objects objectAtIndex:0]];
//            controller.annotation = [events objectAtIndex:0];
//            [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
//            Mixpanel *mixpanel = [Mixpanel sharedInstance];
//            [mixpanel track:@"GymBudEventsTVC SelectedRow" properties:@{
//                                                                   }];
//        }
//    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ()

- (void)distanceFilterDidChange:(NSNotification *)note {
    [self loadObjects];
}

- (void)locationDidChange:(NSNotification *)note {
    NSLog(@"Location did change");
    [self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

//- (void)toggleMapTable:(id)sender {
//    NSLog(@"toggle map table");
//    if(!self.isShowingMap) {
//        // show map
//        PAWWallViewController *wvc = [[PAWWallViewController alloc] init];
//        [self.navigationController pushViewController:wvc animated:YES];
//        self.isShowingMap = YES;
//    } else {
//        [self.navigationController popViewControllerAnimated:YES];
//        self.isShowingMap = NO;
//    }
//    
//}

//- (IBAction)toggleHalfModal:(id)sender {
//    if (self.childViewControllers.count == 0) {
//        self.opaqueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//        self.opaqueView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
//        
//        [self.view addSubview:self.opaqueView];
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"FilterStoryboard" bundle:nil];
//        self.modal = [sb instantiateViewControllerWithIdentifier:@"FilterViewController"];
//        [self addChildViewController:self.modal];
//        self.modal.view.frame = CGRectMake(0, 568, 320, 284);
//        [self.view addSubview:self.modal.view];
//        
//        UIBarButtonItem *filterModalViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHalfModal:)];
//        self.navigationItem.leftBarButtonItem = filterModalViewButton;
//
//        [UIView animateWithDuration:1.0
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             self.modal.view.frame = CGRectMake(0, 284, 320, 284);
//                         } completion:^(BOOL finished) {
//                             [self.modal didMoveToParentViewController:self];
//                         }];
//    } else {
//        UIBarButtonItem *filterModalViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHalfModal:)];
//        self.navigationItem.leftBarButtonItem = filterModalViewButton;
//        [self.opaqueView removeFromSuperview];
//        GBEventsFilterViewController *vc = (GBEventsFilterViewController *)self.modal;
//        NSArray *indexOfActivies = vc.selectedActivities;
//        NSMutableArray *actualActivities = [[NSMutableArray alloc] initWithCapacity:[indexOfActivies count]];
//        for(NSIndexPath *path in indexOfActivies) {
//            [actualActivities addObject:[kGymBudActivities objectAtIndex:path.row]];
//        }
//        
//        if([actualActivities count] == 0) {
//            self.activityFilters = nil;
//        } else {
//            self.activityFilters = actualActivities;
//        }
//        
//        [self loadObjects];
//        [UIView animateWithDuration:1.0
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseIn
//                         animations:^{
//                             self.modal.view.frame = CGRectMake(0, 568, 320, 284);
//                         } completion:^(BOOL finished) {
//                             [self.modal.view removeFromSuperview];
//                             [self.modal removeFromParentViewController];
//                             self.modal = nil;
//                         }];
//
//    }
//}

#pragma mark - CLLocationManagerDelegate methods and helpers

- (void)startStandardUpdates {
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    
    if([CLLocationManager locationServicesEnabled] && CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    CLLocation *currentLocation = self.locationManager.location;
    if (currentLocation) {
        appDelegate.currentLocation = currentLocation;
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"kCLAuthorizationStatusAuthorized");
            [self.locationManager startUpdatingLocation];
//            [self.locationManager requestWhenInUseAuthorization];
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
            [self.locationManager requestWhenInUseAuthorization];
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
    
    [self loadObjects];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Error: %@", [error description]);
    
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
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

@end
