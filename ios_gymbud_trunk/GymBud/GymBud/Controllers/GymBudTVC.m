//
//  GymBudTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 9/28/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
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

#define kCellHeight 70

@implementation GymBudTVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreatePostNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if (NSClassFromString(@"UIRefreshControl")) {
        // Use the new iOS 6 refresh control.
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.pullToRefreshEnabled = NO;
    }
    
    self.tableView.separatorColor = [UIColor whiteColor];
    self.navigationItem.title = @"Local GymBuds";
    self.objectsPerPage = 25;
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
    self.HUD.color = [UIColor clearColor];
    
    [self.HUD show:YES];
    [self setLoadingViewEnabled:NO];

    return query;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}


// Override to customize the look of the cell that allows the user to load the next page of objects.
// The default implementation is a UITableViewCellStyleDefault cell with simple labels.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"Load more...";
    cell.imageView.image = [UIImage imageNamed:@"other.png"];
    cell.imageView.layer.cornerRadius = 30.0f;
    cell.imageView.layer.masksToBounds = YES;
    CGSize itemSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIColor * color = kGymBudLightBlue;
    cell.backgroundColor = color;
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"friend"
                                                forIndexPath:indexPath];
    
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

                              NSString *text3 = [NSString stringWithFormat:@"Mutual GymBuds: %ld", (result[@"context"][@"mutual_friends"][@"summary"][@"total_count"] ? [((NSString*)result[@"context"][@"mutual_friends"][@"summary"][@"total_count"]) integerValue] : 0)];
                              NSLog(@"cell.text3.text is: %@", text3);
                              cell.detailTextLabel.numberOfLines = 2;
                              NSUInteger numberOfOccurrences = [[cell.detailTextLabel.text componentsSeparatedByString:@"\n"] count] - 1;
                              if (numberOfOccurrences==0)
                              {
                                  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n"
                                                               @"%@", cell.detailTextLabel.text, text3];
                                  [cell.detailTextLabel sizeToFit];
                              }
                          }];
    
    if(object[@"gymbudProfile"][@"name"])
        cell.textLabel.text = object[@"gymbudProfile"][@"name"];
    else
        cell.textLabel.text = object[kFacebookUsername];
    
    NSString *text2Text = @"";
    if(object[@"gymbudProfile"][@"preferred"]) {
        text2Text = [[text2Text stringByAppendingString:@"Preferred Time: "] stringByAppendingString:[kPreferredTimesShort objectAtIndex:[kPreferredTimes indexOfObject:object[@"gymbudProfile"][@"preferred"]]]];
    } else {
        text2Text = @"Workout Time Unspecified";
    }
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", text2Text];
    [cell.detailTextLabel sizeToFit];

    UIColor * color = kGymBudLightBlue;
    cell.backgroundColor = color;
    cell.imageView.image = [UIImage imageNamed:@"yogaIcon.png"];

    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    PFFile *theImage = [object objectForKey:@"gymbudProfile"][@"profilePicture"];
    __weak UITableViewCell *weakCell = cell;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        NSLog(@"+++++++++ Loading image view with real data ++++++++");
        weakCell.imageView.image = [UIImage imageWithData:data];
        weakCell.imageView.layer.cornerRadius = 30.0f;
        weakCell.imageView.layer.masksToBounds = YES;
        CGSize itemSize = CGSizeMake(60, 60);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [weakCell.imageView.image drawInRect:imageRect];
        weakCell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }];

    cell.imageView.layer.cornerRadius = 30.0f;
    cell.imageView.layer.masksToBounds = YES;
    CGSize itemSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row >= [self.objects count]) {
        [self loadNextPage];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"GymBudTVC SelectedRow LoadMore" properties:@{
                                                                       }];

    } else {
        GymBudDetailsVC *detailsVC = [[GymBudDetailsVC alloc] init];
        
        detailsVC.user = [self.objects objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detailsVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"GymBudTVC SelectedRow" properties:@{
                                                              }];
        
    }
    
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl
{
    [self loadObjects];
}

@end
