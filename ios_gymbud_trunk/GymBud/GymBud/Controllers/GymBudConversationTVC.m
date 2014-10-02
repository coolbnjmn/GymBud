//
//  GymBudConversationTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 10/1/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudConversationTVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GymBudConstants.h"
#import "GymBudBasicCell.h"

@interface GymBudConversationTVC ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property NSString *reuseId;

@end

@implementation GymBudConversationTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reuseId = @"GymBudBasicCell";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"GymBudBasicCell" bundle:nil] forCellReuseIdentifier:self.reuseId];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.objects count];
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    //    if (![PFUser currentUser]) {
    //        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    //        [query setLimit:0];
    //        return query;
    //    }
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [toUserQuery whereKey:@"toUser" equalTo:self.toUser];
    [toUserQuery whereKey:@"fromUser" equalTo:self.fromUser];
    [toUserQuery whereKey:@"type" equalTo:@"message"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [fromUserQuery whereKey:@"fromUser" equalTo:self.toUser];
    [fromUserQuery whereKey:@"toUser" equalTo:self.fromUser];
    [fromUserQuery whereKey:@"type" equalTo:@"message"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:toUserQuery,fromUserQuery,nil]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
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

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.HUD hide:YES];
    
    self.tableView.tableHeaderView = nil;
    self.tableView.scrollEnabled = YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    GymBudBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseId forIndexPath:indexPath];
    
    
    if(cell == nil) {
        cell = [[GymBudBasicCell alloc] init];
    }

    cell.pictureImageView.image = [UIImage imageNamed:@"yogaIcon.png"];

    if([[object objectForKey:@"fromUser"][@"profile"][@"name"] isEqualToString:[PFUser currentUser][@"profile"][@"name"]]) {
        cell.text1.text = @"You";
        cell.text2.text = [object objectForKey:@"content"];
        
        PFFile *theImage = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
        __weak GymBudBasicCell *weakCell = cell;
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            NSLog(@"+++++++++ Loading image view with real data ++++++++");
            weakCell.pictureImageView.image = [UIImage imageWithData:data];
        }];
    } else {
        if([object objectForKey:@"fromUser"][@"gymbudProfile"]) {
            cell.text1.text = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"name"];
        } else {
            cell.text1.text = [object objectForKey:@"fromUser"][@"profile"][@"name"];
        }
        cell.text2.text = [object objectForKey:@"content"];
        
        PFFile *theImage = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
        __weak GymBudBasicCell *weakCell = cell;
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            NSLog(@"+++++++++ Loading image view with real data ++++++++");
            weakCell.pictureImageView.image = [UIImage imageWithData:data];
        }];
    }
    cell.backgroundColor = [UIColor grayColor];
    cell.text3.text = @"";
    
    cell.pictureImageView.layer.cornerRadius = 8.0f;
    cell.pictureImageView.layer.masksToBounds = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

@end
