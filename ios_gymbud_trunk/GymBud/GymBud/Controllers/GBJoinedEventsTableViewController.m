//
//  GBJoinedEventsTableViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 12/12/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GBJoinedEventsTableViewController.h"
#import "MBProgressHUD.h"
#import "GymBudConstants.h"
#import "Mixpanel.h"
#import "EventDetailsTableViewController.h"

#define kCellHeight 100

@interface GBJoinedEventsTableViewController () <UISearchDisplayDelegate>
@property NSString *reuseId;
@property MBProgressHUD *HUD;
@end

@implementation GBJoinedEventsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Whether the built-in pagination is enabled
    self.paginationEnabled = YES;

    // Do any additional setup after loading the view.
    self.reuseId = @"GymBudEventsCell";
    // The className to query on
    self.parseClassName = @"Event";
    
    // The number of objects to show per page
    self.objectsPerPage = 100;
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:118.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    
    self.tableView.separatorColor = [UIColor whiteColor];
    self.navigationItem.title = @"Your Events";
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    /*the search bar widht must be > 1, the height must be at least 44
     (the real size of the search bar)*/
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    /*contents controller is the UITableViewController, this let you to reuse
     the same TableViewController Delegate method used for the main table.*/
    
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    //set the delegate = self. Previously declared in ViewController.h
    
    self.tableView.tableHeaderView = searchBar; //this line add the searchBar
    //on the top of tableView.
    self.tableView.backgroundColor = kGymBudLightBlue;

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreatePostNotification" object:nil];
}

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    [self filterResults:searchString];
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.HUD hide:YES];
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    //    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    // Query for posts near our current location.
    self.parseClassName = @"Event";
    
    PFQuery *attendeeQuery = [PFQuery queryWithClassName:self.parseClassName];
    PFQuery *organizerQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    NSLog(@"current user is %@", [PFUser currentUser]);
    
    [attendeeQuery whereKey:@"attendees" containsAllObjectsInArray:[NSArray arrayWithObjects:[PFUser currentUser], nil]];
     
    [organizerQuery whereKey:@"organizer" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[organizerQuery, attendeeQuery]];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        query.cachePolicy = kPFCachePolicyIgnoreCache;
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
    self.HUD.color = [UIColor clearColor];
    
    [self.HUD show:YES];
    for (UIView *subview in self.view.subviews)
    {
        if ([subview class] == NSClassFromString(@"PFLoadingView"))
        {
            [subview removeFromSuperview];
            break;
        }
    }
    [self setLoadingViewEnabled:NO];
    
    return query;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight + 20;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - ()

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"prepare for segue");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    EventDetailsTableViewController *dest = [segue destinationViewController];
    [dest setObjectList:self.objects[path.row]];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    
}

@end
