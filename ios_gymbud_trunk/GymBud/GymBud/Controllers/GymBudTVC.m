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
#import "GymBudTVC.h"

@interface GymBudTVC ()

@property NSString *reuseId;
@property MBProgressHUD *HUD;

@end

#define kCellHeight 80

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
    [self.HUD hide:YES];
    NSLog(@"objectsDidLoad GymBudTVC");
    // This method is called every time objects are loaded from Parse via the PFQuery
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
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
                              NSLog(@"result is :%@ for user: %@", result[@"context"][@"mutual_friends"][@"data"], object[@"profile"][@"facebookId"]);
                              NSLog(@"result count is : %lu", (unsigned long)[result[@"context"][@"mutual_friends"][@"data"] count]);
                              cell.text3.text = [NSString stringWithFormat:@"%lu", [result[@"context"][@"mutual_friends"][@"data"] count]];
                          }];
    
    if(object[@"gymbudProfile"][@"name"]) {
        cell.text1.text = object[@"gymbudProfile"][@"name"];
    } else {
        cell.text1.text = object[kFacebookUsername];
    }
    
    NSString *interests = @"";
    if(object[@"gymbudProfile"][@"interest1"]) {
        interests = [interests stringByAppendingString:object[@"gymbudProfile"][@"interest1"]];
        interests = [interests stringByAppendingString:@" "];
        interests = [interests stringByAppendingString:object[@"gymbudProfile"][@"interest2"]];
        interests = [interests stringByAppendingString:@" "];
        interests = [interests stringByAppendingString:object[@"gymbudProfile"][@"interest3"]];
    }
    cell.text2.text = interests;
    
    cell.backgroundColor = [UIColor grayColor];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
