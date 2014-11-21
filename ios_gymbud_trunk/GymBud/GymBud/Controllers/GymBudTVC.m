//
//  GymBudTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 9/28/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "GymBudBasicCell.h"
#import "GymBudConstants.h"
#import "GymBudDetailsVC.h"
#import "GymBudTVC.h"
#import "Mixpanel.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface GymBudTVC ()

@property NSString *reuseId;
@property MBProgressHUD *HUD;
@property NSMutableArray *sortedByMutualFriendsObjects;

@end

#define kCellHeight 90

@implementation GymBudTVC

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Customize the table:
        
        // The className to query on
        self.parseClassName = @"User";
        self.reuseId = @"GymBudBasicCell";
        
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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GymBudBasicCell" bundle:nil] forCellReuseIdentifier:self.reuseId];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.navigationItem.title = @"Local GymBuds";
    
    self.navigationItem.hidesBackButton = YES;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    NSLog(@"objectsDidLoad GymBudTVC");
  if (NSClassFromString(@"UIRefreshControl")) {
      [self.refreshControl endRefreshing];
  }
  [self.HUD hide:YES];

//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                            @"context.fields(mutual_friends)", @"fields",
//                                                            nil
//                                                            ];
//    
//    self.sortedByMutualFriendsObjects = [[NSMutableArray alloc] init];
    
//    for(int i = 0; i < [self.objects count]; i++) {
//        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", self.objects[i][@"profile"][@"facebookId"]]
//                                     parameters:params
//                                     HTTPMethod:@"GET"
//                              completionHandler:^(
//                                                  FBRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error
//                                                  ) {
//                                  NSLog(@"result count is : %lu", (unsigned long)result[@"context"][@"mutual_friends"][@"summary"][@"total_count"]);
//                                  
//                                  NSMutableDictionary *tuple = [[NSMutableDictionary alloc] init];
//                                  [tuple setObject:[NSNumber numberWithInt:i] forKey:@"objectsIndex"];
//                                  [tuple setObject:[NSNumber numberWithInt:[((NSString*)result[@"context"][@"mutual_friends"][@"summary"][@"total_count"]) integerValue]] forKey:@"mutual_friends_count"];
//                                  [self.sortedByMutualFriendsObjects addObject:tuple];
//                                  NSLog(@"added tuple");
//                                  if([self.sortedByMutualFriendsObjects count] == [self.objects count]) {
//                                      [self.sortedByMutualFriendsObjects sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                                          return (obj1[@"mutual_friends_count"] < obj2[@"mutual_friends_count"] ?  NSOrderedDescending :  NSOrderedAscending);
//                                      }];
//                                      NSLog(@"helloooo");
//                                      NSLog(@"%@", self.sortedByMutualFriendsObjects);
//                                      // This method is called every time objects are loaded from Parse via the PFQuery
//                                      if (NSClassFromString(@"UIRefreshControl")) {
//                                          [self.refreshControl endRefreshing];
//                                      }
//                                      [self.tableView reloadData];
//                                      [self.HUD hide:YES];
//
//                                  }
//                              }];
//
//    }
    


}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFUser query];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
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
    GymBudBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseId forIndexPath:indexPath];
    
    
    if(cell == nil) {
        cell = [[GymBudBasicCell alloc] init];
    }
    
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"context.fields(mutual_friends)", @"fields",
                            nil
                            ];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", object[@"profile"][@"facebookId"]]
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSLog(@"result is :%@ for user: %@", result[@"context"][@"mutual_friends"][@"summary"][@"total_count"], object[@"profile"][@"facebookId"]);
                             
                              cell.text3.text = [NSString stringWithFormat:@"Mutual GymBuds: %ld", (result[@"context"][@"mutual_friends"][@"summary"][@"total_count"] ? [((NSString*)result[@"context"][@"mutual_friends"][@"summary"][@"total_count"]) integerValue] : 0)];
                              NSLog(@"cell.text3.text is: %@", cell.text3.text);
                          }];
//    NSLog(@"sortedMutualFriends count: %ld", [self.sortedByMutualFriendsObjects count]);
//    PFObject *theObject;
//    NSNumber *mutual_friends_count;
//    
//    if([self.sortedByMutualFriendsObjects count] < [self.objects count]) {
//        theObject = object;
//    } else {
//        NSNumber *actualIndex = [self.sortedByMutualFriendsObjects objectAtIndex:indexPath.row][@"objectsIndex"];
//        NSLog(@"the actual index is : %d", [actualIndex intValue]);
//        theObject = [self.objects objectAtIndex:[actualIndex intValue]];
//        mutual_friends_count = [self.sortedByMutualFriendsObjects objectAtIndex:indexPath.row][@"mutual_friends_count"];
//
//    }
    
//    PFObject *theObject = [self.objects objectAtIndex:actualIndex];
    if(object[@"gymbudProfile"][@"name"]) {
        cell.text1.text = object[@"gymbudProfile"][@"name"];
    } else {
        cell.text1.text = object[kFacebookUsername];
    }
    
//    cell.logo1.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:object[@"gymbudProfile"][@"interest1"]]];
//    cell.logo2.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:object[@"gymbudProfile"][@"interest2"]]];
//    cell.logo3.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:object[@"gymbudProfile"][@"interest3"]]];
    
    NSString *text2Text = @"";
    if(object[@"gymbudProfile"][@"preferred"]) {
        text2Text = [[text2Text stringByAppendingString:@"Preferred Time: "] stringByAppendingString:[kPreferredTimesShort objectAtIndex:[kPreferredTimes indexOfObject:object[@"gymbudProfile"][@"preferred"]]]];
    } else {
        text2Text = @"Workout Time Unspecified";
    }
    
//    cell.text3.text = [NSString stringWithFormat:@"Mutual Friends: %d", [mutual_friends_count intValue]];
    cell.text2.text = text2Text;
    UIColor * color = [UIColor colorWithRed:178/255.0f green:168/255.0f blue:151/255.0f alpha:1.0f];
    cell.backgroundColor = color;
    cell.pictureImageView.image = [UIImage imageNamed:@"yogaIcon.png"];

    PFFile *theImage = [object objectForKey:@"gymbudProfile"][@"profilePicture"];
    __weak GymBudBasicCell *weakCell = cell;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        NSLog(@"+++++++++ Loading image view with real data ++++++++");
        weakCell.pictureImageView.image = [UIImage imageWithData:data];
    }];
    //        self.headerImageView.image = [UIImage imageWithData:imageData];
    cell.pictureImageView.layer.cornerRadius = 8.0f;
    cell.pictureImageView.layer.masksToBounds = YES;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GymBudDetailsVC *detailsVC = [[GymBudDetailsVC alloc] init];
//    if([self.sortedByMutualFriendsObjects count] == [self.objects count]) {
//        detailsVC.user = [self.objects objectAtIndex:[[self.sortedByMutualFriendsObjects objectAtIndex:indexPath.row][@"objectsIndex"] intValue]];
//    } else {
        detailsVC.user = [self.objects objectAtIndex:indexPath.row];
//    }
    [self.navigationController pushViewController:detailsVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"GymBudTVC SelectedRow" properties:@{
                                                           }];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}
@end
