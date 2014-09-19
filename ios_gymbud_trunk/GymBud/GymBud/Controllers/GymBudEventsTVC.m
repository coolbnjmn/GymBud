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
#import "NSDate+Utilities.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "GBEventsFilterViewController.h"

#define kCellHeight 100

@interface GymBudEventsTVC ()

@property NSString *reuseId;
@property MBProgressHUD *HUD;
@property (strong,nonatomic) UIViewController *modal;
@property (strong, nonatomic) UIView *opaqueView;
@property (nonatomic, strong) NSArray *activityFilters;

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
    self.navigationItem.title = @"Local GymBuds";
    
    UIImage *buttonImage = [UIImage imageNamed:@"mapTableToggle1.png"];
    UIBarButtonItem *mapToTableViewButton = [[UIBarButtonItem alloc] initWithImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMapTable:)];
    
    UIBarButtonItem *filterModalViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHalfModal:)];
    self.navigationItem.leftBarButtonItem = filterModalViewButton;
    self.navigationItem.rightBarButtonItem = mapToTableViewButton;
    self.navigationItem.hidesBackButton = YES;
    
    self.isShowingMap = NO;

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
    [query orderByAscending:@"time"];
    if(self.activityFilter != nil) {
        [query whereKey:@"activity" equalTo:self.activityFilter];
    }
    if(self.timeFiler != nil) {
        [query whereKey:@"time" greaterThan:self.timeFiler];
    }
    
    if(self.activityFilters != nil) {
        [query whereKey:@"activity" containedIn:self.activityFilters];
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
    self.HUD.color = [UIColor whiteColor];
    
    [self.HUD show:YES];
    [self setLoadingViewEnabled:NO];
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
    
    NSString *name;
    if([object objectForKey:@"organizer"][@"gymbudProfile"][@"name"]) {
        name = [object objectForKey:@"organizer"][@"gymbudProfile"][@"name"];
    } else {
        name = [[object objectForKey:@"organizer"] objectForKey:kFacebookUsername];
    }
    cell.nameTextLabel.text = name;
    cell.capacityTextLabel.text = @"TBD";
    
    NSDate *eventStartTime = [object objectForKey:@"time"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    cell.startTimeTextLabel.text = [formatter stringFromDate:eventStartTime];
    cell.activityTextLabel.text = [object objectForKey:@"activity"];
    cell.backgroundColor = [UIColor grayColor];
        
    PFFile *theImage = [object objectForKey:@"organizer"][@"gymbudProfile"][@"profilePicture"];
    cell.logoImageView.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:[object objectForKey:@"activity"]]];
    
    __weak GymBudEventsCell *weakCell = cell;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        NSLog(@"+++++++++ Loading image view with real data ++++++++");
        weakCell.logoImageView.image = [UIImage imageWithData:data];
        [weakCell setNeedsLayout];
    }];

    
    if([eventStartTime isToday]) {
        cell.startDateTextLabel.text = @"Today";
    } else if([eventStartTime isTomorrow]) {
        cell.startDateTextLabel.text = @"Tomorrow";
    } else {
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setDateFormat:@"MM/dd"];
        cell.startDateTextLabel.text = [formatter2 stringFromDate:eventStartTime];
    }
    cell.locationTextLabel.text = [object objectForKey:@"locationName"];
    
    NSString *countOverCapacity;
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)[((NSArray *)[object objectForKey:@"attendees"]) count]];
    NSString *capacity = [NSString stringWithFormat:@"%ld", (long)[[object objectForKey:@"count"] integerValue]];
    countOverCapacity = [[count stringByAppendingString:@"/"] stringByAppendingString:capacity];
    cell.capacityTextLabel.text = countOverCapacity;
    
    NSArray *subLogoIndices = [object objectForKey:@"detailLogoIndices"];
    int subLogoIndex = 0;
    for(NSNumber *index in subLogoIndices) {
        if(subLogoIndex == 0) {
            cell.subLogoImageView1.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
        } else if(subLogoIndex == 1) {
            cell.subLogoImageView2.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
        } else if(subLogoIndex == 2) {
            cell.subLogoImageView3.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
        } else {
            cell.subLogoImageView4.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
        }
        subLogoIndex++;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UserDetailsViewController *controller = [[UserDetailsViewController alloc] initWithNibName:nil
                                                                                        bundle:nil];
    GymBudEventsCell *cell = (GymBudEventsCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"organizer"];
    [query whereKey:@"activity" containsString:cell.activityTextLabel.text];
    [query whereKey:@"locationName" containsString:cell.locationTextLabel.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(self.navigationController.topViewController == self) {
            GymBudEventModel *post = [[GymBudEventModel alloc] initWithPFObject:[objects objectAtIndex:0]];
            controller.annotation = post;
            [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
        }
    }];
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

- (void)toggleMapTable:(id)sender {
    NSLog(@"toggle map table");
    if(!self.isShowingMap) {
        // show map
        PAWWallViewController *wvc = [[PAWWallViewController alloc] init];
        [self.navigationController pushViewController:wvc animated:YES];
        self.isShowingMap = YES;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        self.isShowingMap = NO;
    }
    
}

- (IBAction)toggleHalfModal:(id)sender {
    if (self.childViewControllers.count == 0) {
        self.opaqueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        self.opaqueView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        
        [self.view addSubview:self.opaqueView];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"FilterStoryboard" bundle:nil];
        self.modal = [sb instantiateViewControllerWithIdentifier:@"FilterViewController"];
        [self addChildViewController:self.modal];
        self.modal.view.frame = CGRectMake(0, 568, 320, 284);
        [self.view addSubview:self.modal.view];
        
        UIBarButtonItem *filterModalViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHalfModal:)];
        self.navigationItem.leftBarButtonItem = filterModalViewButton;

        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.modal.view.frame = CGRectMake(0, 284, 320, 284);
                         } completion:^(BOOL finished) {
                             [self.modal didMoveToParentViewController:self];
                         }];
    } else {
        UIBarButtonItem *filterModalViewButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHalfModal:)];
        self.navigationItem.leftBarButtonItem = filterModalViewButton;
        [self.opaqueView removeFromSuperview];
        GBEventsFilterViewController *vc = (GBEventsFilterViewController *)self.modal;
        NSArray *indexOfActivies = vc.selectedActivities;
        NSMutableArray *actualActivities = [[NSMutableArray alloc] initWithCapacity:[indexOfActivies count]];
        for(NSIndexPath *path in indexOfActivies) {
            [actualActivities addObject:[kGymBudActivities objectAtIndex:path.row]];
        }
        
        if([actualActivities count] == 0) {
            self.activityFilters = nil;
        } else {
            self.activityFilters = actualActivities;
        }
        
        [self loadObjects];
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.modal.view.frame = CGRectMake(0, 568, 320, 284);
                         } completion:^(BOOL finished) {
                             [self.modal.view removeFromSuperview];
                             [self.modal removeFromParentViewController];
                             self.modal = nil;
                         }];

    }
}

@end
