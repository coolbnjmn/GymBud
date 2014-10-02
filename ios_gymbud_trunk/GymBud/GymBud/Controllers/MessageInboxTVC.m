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
@end

@implementation MessageInboxTVC
@synthesize lastRefresh;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithTitle:@"Send Message" style:UIBarButtonItemStyleBordered target:self action:@selector(sendMessage:)];
    
    self.navigationItem.title = @"Inbox";
    self.navigationItem.rightBarButtonItem = messageButton;
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
    self.HUD.color = [UIColor whiteColor];

    [self.HUD show:YES];
    [self setLoadingViewEnabled:NO];
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
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
    GymBudConversationTVC *convoTVC = [[GymBudConversationTVC alloc] init];
    convoTVC.fromUser = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"fromUser"];
    convoTVC.toUser = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"toUser"];
    
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
