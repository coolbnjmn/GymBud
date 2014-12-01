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

    self.navigationItem.title = @"Inbox";
    self.navigationItem.rightBarButtonItem = messageButton;
    
    
    
//    UIView *editToast = [[UIView alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height - 40, self.window.bounds.size.width, 40)];
//    editToast.backgroundColor = [UIColor orangeColor];
//    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, 40)];
//    textLabel.text = @"Edit profile (from Settings tab) now!";
//    textLabel.textAlignment = NSTextAlignmentCenter;
//    [editToast addSubview:textLabel];
//    UIApplication *app = [UIApplication sharedApplication];
//    editToast.frame = CGRectMake(0, self.window.bounds.size.height - 40 - tbc.tabBar.bounds.size.height, self.window.bounds.size.width, 40);
//    [app.keyWindow addSubview:editToast];
    //        [UIView animateWithDuration:1.0
    //                              delay:0.0
    //                            options:UIViewAnimationOptionCurveEaseIn
    //                         animations:^{
    //                            editToast.frame = CGRectMake(0, self.window.bounds.size.height - 40 - tbc.tabBar.bounds.size.height, self.window.bounds.size.width, 40);
    //                         }
    //                         completion:^(BOOL finished) {
    //                                // register the field in notification center.
    //                         }];
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
        
//        NSUInteger userHash = ((NSString *)toUser[@"username"]).hash + ((NSString *)fromUser[@"username"]).hash;
//        NSString *hash = [[toUser[kFacebookUsername] stringByAppendingString:@" "] stringByAppendingString:fromUser[kFacebookUsername]];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *hash = [self sportTypeForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:hash];
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sportType = [self sportTypeForSection:section];
    return sportType;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    labelHeader.textColor = kGymBudLightBlue;
    [headerView addSubview:labelHeader];
    headerView.backgroundColor = [UIColor whiteColor];
    labelHeader.text = [self sportTypeForSection:section];
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    
    if(cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MessageCell"];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *when = [dateFormatter stringFromDate:[object createdAt]];
    
//    BOOL isYouMessage = ![[[object objectForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    
//    if(isYouMessage) {
        if([[[object objectForKey:@"fromUser"] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
            cell.detailTextLabel.text = [[[[[object objectForKey:@"fromUser"] objectForKey:@"gymbudProfile"] objectForKey:@"name"] stringByAppendingString:@" : "] stringByAppendingString:when];
        } else {
            cell.detailTextLabel.text = [[[[[object objectForKey:@"fromUser"] objectForKey:@"profile"] objectForKey:@"name"] stringByAppendingString:@" : "] stringByAppendingString:when];
        }
        
        if([[object objectForKey:@"unread"] boolValue]) {
            cell.textLabel.text = [@"(1) " stringByAppendingString:[object objectForKey:@"content"]];
        } else {
            cell.textLabel.text = [object objectForKey:@"content"];
        }
//    }
//    else {
//        if([[[object objectForKey:@"toUser"] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
//            cell.textLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Sent to: %@", [[[object objectForKey:@"toUser"] objectForKey:@"gymbudProfile"] objectForKey:@"name"]]  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13], NSFontAttributeName, nil]];
//            
//        } else {
//            cell.textLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Sent to: %@", [[[object objectForKey:@"toUser"] objectForKey:@"profile"] objectForKey:@"name"]]  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13], NSFontAttributeName, nil]];
//        }
//        
//        cell.detailTextLabel.text = [object objectForKey:@"content"];
//    }
    
    cell.backgroundColor = kGymBudLightBlue;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    return cell;
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
    
    GymBudConversationTVC *convoTVC = [[GymBudConversationTVC alloc] init];
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
