//
//  MessageInboxTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/20/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "MessageInboxTVC.h"
#import "ViewMessageVC.h"
#import "FindUserTVC.h"
#import "GymBudConstants.h"
#import "MBProgressHUD.h"
#import "BubbleChatTVC.h"
#import "GymBudConversationTVC.h"

@interface MessageInboxTVC ()

@property (weak, nonatomic) NSDate *lastRefresh;
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToConversationMap;

@end

@implementation MessageInboxTVC
@synthesize lastRefresh;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithTitle:@"Compose" style:UIBarButtonItemStyleBordered target:self action:@selector(sendMessage:)];
    self.sections = [NSMutableDictionary dictionary];
    self.sectionToConversationMap = [NSMutableDictionary dictionary];

    self.tableView.backgroundColor = kGymBudGrey;
    self.navigationItem.title = @"Inbox";
    self.navigationItem.rightBarButtonItem = messageButton;
    [self loadObjects];
}

-(void)sendMessage:(id) sender {
    // about to message user
    
    NSLog(@"gonna go find a user to message");
    FindUserTVC *controller = [[FindUserTVC alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController
- (NSString *)sportTypeForSection:(int)section {
    return [self.sectionToConversationMap objectForKey:[NSNumber numberWithInt:section]];
}


- (PFQuery *)queryForTable {
    
//    if (![PFUser currentUser]) {
//        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
//        [query setLimit:0];
//        return query;
//    }
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [toUserQuery whereKey:@"type" equalTo:@"message"];
    
//    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Activity"];
//    [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
//    [fromUserQuery whereKey:@"type" equalTo:@"message"];
//    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:toUserQuery,nil]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    if(!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.HUD];
    }
    
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
    
    if([self.HUD isHidden]) {
        [self.HUD show:YES];
    }
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

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *hash = [self sportTypeForSection:indexPath.section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:hash];
    
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}

- (void)objectsDidLoad:(NSError *)error {
    // This method is called every time objects are loaded from Parse via the PFQuery
    
    [self.sections removeAllObjects];
    [self.sectionToConversationMap removeAllObjects];
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    for (PFObject *object in self.objects) {
        PFUser *toUser = [object objectForKey:@"toUser"];
        PFUser *fromUser = [object objectForKey:@"fromUser"];
        
        NSString *hash = fromUser[@"gymbudProfile"][@"name"] ? : fromUser[kFacebookUsername];
        NSMutableArray *objectsInSection = [self.sections objectForKey:hash];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
            // this is the first time we see this sportType - increment the section index
            [self.sectionToConversationMap setObject:hash forKey:[NSNumber numberWithInt:section++]];
            [objectsInSection addObject:[NSNumber numberWithInt:rowIndex]];
        }
        rowIndex++;
        [self.sections setObject:objectsInSection forKey:hash];
    }
    
    [super objectsDidLoad:error];
    [self.HUD hide:YES];

    lastRefresh = [NSDate date];
//    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.tableView.tableHeaderView = nil;
    self.tableView.scrollEnabled = YES;
    
//    NSUInteger unreadCount = 0;
//    for (PFObject *activity in self.objects) {
//        if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
//            unreadCount++;
//        }
//    }
//    
//    if (unreadCount > 0) {
//        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",unreadCount];
//    } else {
//        self.navigationController.tabBarItem.badgeValue = nil;
//    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *hash = [self sportTypeForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:hash];
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSString *sportType = [self sportTypeForSection:section];
//    return sportType;
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    labelHeader.textColor = kGymBudLightBlue;
//    [headerView addSubview:labelHeader];
//    headerView.backgroundColor = [UIColor whiteColor];
//    labelHeader.text = [self sportTypeForSection:section];
//    return headerView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 6)];
    headerView.backgroundColor = kGymBudLightBlue;
    return headerView;
    
    //    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"message"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *when = [dateFormatter stringFromDate:[object createdAt]];
    
//    BOOL isYouMessage = ![[[object objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    
//    if(isYouMessage) {
        if([[[object objectForKey:@"fromUser"] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
            cell.textLabel.text = [[[object objectForKey:@"fromUser"] objectForKey:@"gymbudProfile"] objectForKey:@"name"];
        } else {
            cell.textLabel.text = [[[object objectForKey:@"fromUser"] objectForKey:@"profile"] objectForKey:@"name"];
        }
        
//        if([[object objectForKey:@"unread"] boolValue]) {
//            cell.detailTextLabel.text = [@"(1) " stringByAppendingString:[object objectForKey:@"content"]];
//        } else {
//            cell.detailTextLabel.text = [object objectForKey:@"content"];
//        }
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", [object objectForKey:@"content"], when];
    [cell.detailTextLabel sizeToFit];

    if([[object objectForKey:@"unread"] boolValue]) {
        cell.backgroundColor = kGymBudGold;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    } else {
        cell.backgroundColor = kGymBudGrey;
        cell.textLabel.textColor = kGymBudLightBlue;
        cell.detailTextLabel.textColor = kGymBudLightBlue;

    }
    
    PFFile *theImage = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
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
    cell.imageView.image = [UIImage imageNamed:@"yogaIcon.png"];
    cell.imageView.layer.cornerRadius = 30.0f;
    cell.imageView.layer.masksToBounds = YES;
    CGSize itemSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"MagistralATT" size:12];

    return (PFTableViewCell *)cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
//    ViewMessageVC *detailViewController = [[ViewMessageVC alloc] init];
//    
//    // Pass the selected object to the new view controller.
//    detailViewController.activity = [[super objects] objectAtIndex:indexPath.row];
//    // Push the view controller.
    NSString *hash = [self sportTypeForSection:indexPath.section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:hash];
    
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    
//    GymBudConversationTVC *convoTVC = [[GymBudConversationTVC alloc] init];
    BubbleChatTVC *convoTVC = [[BubbleChatTVC alloc] init];
    convoTVC.fromUser = [[self.objects objectAtIndex:[rowIndex intValue]] objectForKey:@"fromUser"];
    convoTVC.toUser = [[self.objects objectAtIndex:[rowIndex intValue]] objectForKey:@"toUser"];
    
    [self.navigationController pushViewController:convoTVC animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
