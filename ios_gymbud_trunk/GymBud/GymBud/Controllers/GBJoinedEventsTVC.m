//
//  GBJoinedEventsTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/28/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GBJoinedEventsTVC.h"
#import "GymBudEventsCell.h"
#import "GymBudEventModel.h"
#import "UserDetailsViewController.h"
#import "GymBudConstants.h"
#import "NSDate+Utilities.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

#define kCellHeight 100

@interface GBJoinedEventsTVC ()

@property NSString *reuseId;
@property MBProgressHUD *HUD;

@end

@implementation GBJoinedEventsTVC

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
    self.navigationItem.title = @"Joined Events";
    
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
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    // Query for posts near our current location.
    PFQuery *attendeeQuery = [PFQuery queryWithClassName:self.parseClassName];
    PFQuery *organizerQuery = [PFQuery queryWithClassName:self.parseClassName];
    


    [attendeeQuery whereKey:@"attendees" containsAllObjectsInArray:[NSArray arrayWithObjects:[PFUser currentUser], nil]];
    [organizerQuery whereKey:@"organizer" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[attendeeQuery, organizerQuery]];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query includeKey:@"organizer"];
    [query whereKey:@"isVisible" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByAscending:@"time"];
    
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
    
    cell.nameTextLabel.text = [[object objectForKey:@"organizer"] objectForKey:kFacebookUsername];
    
    NSDate *eventStartTime = [object objectForKey:@"time"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    cell.startTimeTextLabel.text = [formatter stringFromDate:eventStartTime];
//    cell.activityTextLabel.text = [object objectForKey:@"activity"];
    cell.activityTextLabel.text = object[@"additional"] ? [[[object objectForKey:@"activity"] stringByAppendingString:@" - "] stringByAppendingString:object[@"additional"]] : object[@"activity"];
    cell.backgroundColor = [UIColor grayColor];
    
    PFFile *theImage = [object objectForKey:@"organizer"][@"gymbudProfile"][@"profilePicture"];
    cell.logoImageView.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:[object objectForKey:@"activity"]]];
    
    __weak GymBudEventsCell *weakCell = cell;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        NSLog(@"+++++++++ Loading image view with real data ++++++++");
        weakCell.logoImageView.image = [UIImage imageWithData:data];
        [weakCell setNeedsLayout];
    }];
//    NSURL *url = [NSURL URLWithString:[[[object objectForKey:@"organizer"] objectForKey:@"profile"] objectForKey:@"pictureURL"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    UIImage *placeholderImage = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:[object objectForKey:@"activity"]]];
//    
//    __weak GymBudEventsCell *weakCell = cell;
//    
//    [cell.logoImageView setImageWithURLRequest:request
//                              placeholderImage:placeholderImage
//                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                           // do we want rounded corners on the image?
//                                           weakCell.logoImageView.image = image;
//                                           [weakCell setNeedsLayout];
//                                       } failure:nil];
    
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
    NSString *count = [NSString stringWithFormat:@"%d", [((NSArray *)[object objectForKey:@"attendees"]) count]];
    NSString *capacity = [NSString stringWithFormat:@"%d", [[object objectForKey:@"count"] integerValue]];
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
    [query whereKey:@"objectId" equalTo:[[self.objects objectAtIndex:indexPath.row] objectId]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if(self.navigationController.topViewController == self) {
//            GymBudEventModel *post = [[GymBudEventModel alloc] initWithPFObject:[objects objectAtIndex:0]];
            controller.annotation = [events objectAtIndex:0];
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

@end
