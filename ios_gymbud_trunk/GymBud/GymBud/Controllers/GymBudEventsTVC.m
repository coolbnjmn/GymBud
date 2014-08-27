//
//  GymBudEventsTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudEventsTVC.h"
#import "GymBudEventsCell.h"
#import "GymBudEventModel.h"
#import "UserDetailsViewController.h"
#import "AppDelegate.h"
#import "GymBudConstants.h"

#define kCellHeight 100

@interface GymBudEventsTVC ()

@property NSString *reuseId;

@end

@implementation GymBudEventsTVC

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Customize the table:
        
        // The className to query on
        self.parseClassName = @"Event";
        self.reuseId = @"GymBudEventsCell";
        
        // The key of the PFObject to display in the label of the default cell style
        self.title = @"GymBud";
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 100;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreatePostNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GymBudEventsCell" bundle:nil] forCellReuseIdentifier:self.reuseId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:@"CreatePostNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:@"LocationChangeNotification" object:nil];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    // TODO: Remove Check in button
    UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStyleBordered target:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] action:@selector(checkInButtonTouchHandler:)];
    self.navigationItem.leftBarButtonItem = checkInButton;
    
    UIImage *buttonImage = [UIImage imageNamed:@"mapTableToggle1.png"];
    UIBarButtonItem *mapToTableViewButton = [[UIBarButtonItem alloc] initWithImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2] action:@selector(toggleMapTable:)];
    self.navigationItem.rightBarButtonItem = mapToTableViewButton;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    NSLog(@"objectsDidLoad GymBudEventsTVC");
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
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
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    //	[query whereKey:@"location" nearGeoPoint:point withinKilometers:100];
    [query includeKey:@"organizer"];
    [query whereKey:@"isVisible" equalTo:[NSNumber numberWithBool:YES]];

    return query;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    GymBudEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseId forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[GymBudEventsCell alloc] init];
    }
    
    cell.nameTextLabel.text = [[object objectForKey:@"organizer"] objectForKey:kFacebookUsername];
    cell.capacityTextLabel.text = @"TBD";
    
    NSDate *eventStartTime = [object objectForKey:@"time"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    cell.startTimeTextLabel.text = [formatter stringFromDate:eventStartTime];
    
    cell.backgroundColor = [UIColor grayColor];
    cell.logoImageView.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:[object objectForKey:@"activity"]]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UserDetailsViewController *controller = [[UserDetailsViewController alloc] initWithNibName:nil
                                                                                        bundle:nil];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
//    [query includeKey:@"organizer"];
//    [query whereKey:@"activity" containsString:((UILabel *)(cell.contentView.subviews[1])).text];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(self.navigationController.topViewController == self) {
//            GymBudEventModel *post = [[GymBudEventModel alloc] initWithPFObject:[objects objectAtIndex:0]];
//            controller.annotation = post;
//            [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
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

- (void)postWasCreated:(NSNotification *)note {
    NSLog(@"post was created");
    [self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

@end