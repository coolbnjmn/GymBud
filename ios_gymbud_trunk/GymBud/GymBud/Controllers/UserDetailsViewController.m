#import "UserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GymBudEventModel.h"
#import "MessageUserVC.h"
#import "GymBudConstants.h"
#import "Mixpanel.h"
#import "GymBudDetailsVC.h"

@implementation UserDetailsViewController
@synthesize annotation;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    self.tableView.backgroundColor = [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    PFObject *event = (PFObject *) annotation;

    if(![[[event objectForKey:@"organizer"] objectId] isEqual:[[PFUser currentUser] objectId]]) {
        UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithTitle:@"Message User" style:UIBarButtonItemStyleBordered target:self action:@selector(messageUser:)];
        self.navigationItem.rightBarButtonItem = messageButton;
    }
    
    
    // Load table header view from nib
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;
    
    // Create array for table row titles
    self.rowTitleArray = @[@"Gender", @"Age", @"Goals", @"Times"];
    
    // Set default values for the table row data
    self.rowDataArray = [@[@"N/A", @"N/A", @"N/A", @"N/A"] mutableCopy];
    
    NSLog(@"annotation is: ");
    NSLog(@"%@", annotation);
    if([event objectForKey:@"organizer"]) {
        [event[@"organizer"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
            [self updateProfileForUser:(PFUser *)object];
            if([[object objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                self.headerJoinButton.hidden = YES;
            }
        }];

    }
    if(event[@"attendees"]) {
        self.attendeesPresent = YES;
        self.attendees = [NSMutableArray arrayWithArray:event[@"attendees"]];
        for(PFUser *attendee in event[@"attendees"]) {
            if([[attendee objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                self.headerJoinButton.hidden = YES;
                break;
            }
        }
    } else {
        self.attendeesPresent = NO;
    }

    UIImage *pictureLogo = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:event[@"activity"]]];
    
    self.headerPictureLogo.image = pictureLogo;
    self.headerCheckinMessage.text = [[event[@"activity"] stringByAppendingString:@". "] stringByAppendingString:event[@"description"] ? : @"No Description Provided"];

//    if([event organizer]) {
//        [[event organizer] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
//            [self updateProfileForUser:(PFUser *)object];
//        }];
//    }
//    
//    if([event attendees]) {
//        for(PFUser *attendee in [event attendees]) {
//            if([[attendee objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
//                self.headerJoinButton.hidden = YES;
//                break;
//            }
//        }
//    }
//    UIImage *pictureLogo = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:event.activity]];
//
//    self.headerPictureLogo.image = pictureLogo;
//    self.headerCheckinMessage.text = [[event.title stringByAppendingString:@". "] stringByAppendingString:event.eventDescription];
}

-(void)messageUser:(id) sender {
    // about to message user
    PFObject *event = (PFObject *) annotation;

    NSLog(@"about to message user");
    MessageUserVC *controller = [[MessageUserVC alloc] initWithNibName:nil bundle:nil];
    controller.user = event[@"organizer"];
    [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"UserDetails MessageUser" properties:@{
                                                           }];
}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.headerImageView.image = [UIImage imageWithData:self.imageData];
    
    // Add a nice corner radius to the image
    self.headerImageView.layer.cornerRadius = 8.0f;
    self.headerImageView.layer.masksToBounds = YES;
}



#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && self.attendeesPresent) {
        GymBudDetailsVC *detailsVC = [[GymBudDetailsVC alloc] init];
        //    if([self.sortedByMutualFriendsObjects count] == [self.objects count]) {
        //        detailsVC.user = [self.objects objectAtIndex:[[self.sortedByMutualFriendsObjects objectAtIndex:indexPath.row][@"objectsIndex"] intValue]];
        //    } else {
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:[[self.attendees objectAtIndex:indexPath.row] objectId]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            NSString *name;
            PFUser *user = [array objectAtIndex:indexPath.row];
            detailsVC.user = user;
            [self.navigationController pushViewController:detailsVC animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"UserDetailsViewController tapAttendee" properties:@{
                                                                  }];
            return;
            
        }];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0 && self.attendeesPresent) {
        return @"Attendees: ";
    } else {
        return @"Organizer Profile";
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.attendeesPresent) {
        return 2;
    } else return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0 && self.attendeesPresent) {
        return [self.attendees count];
    } else {
        return self.rowTitleArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && self.attendeesPresent) {
        return 50.0f;
    } else {
        if(indexPath.row < 2) {
            return 44.0f;
        } else {
            return 180.0f;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *BigCellIdentifier = @"BigCell";
    
    UITableViewCell *cell;
    
    if(indexPath.section == 0 && self.attendeesPresent) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:[[self.attendees objectAtIndex:indexPath.row] objectId]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            NSString *name;
            PFUser *user = [array objectAtIndex:indexPath.row];
            if([[user objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
                name = [[user objectForKey:@"gymbudProfile"] objectForKey:@"name"];
            } else {
                name = [[user objectForKey:@"profile"] objectForKey:@"name"];
            }
            cell.textLabel.text = name;
        }];
        cell.textLabel.text = @"Joined person";
        return cell;
    }
    
    if(indexPath.row < 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:BigCellIdentifier];
    }
    
    if (cell == nil && indexPath.row < 2) {
        // Create the cell and add the labels
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 120.0f, 44.0f)];
        titleLabel.tag = 1; // We use the tag to set it later
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake( 130.0f, 0.0f, 165.0f, 44.0f)];
        dataLabel.tag = 2; // We use the tag to set it later
        dataLabel.font = [UIFont systemFontOfSize:15.0f];
        dataLabel.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:dataLabel];
    } else if(cell == nil) {
        // Create the cell and add the labels
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BigCellIdentifier];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 320.0f, 20.0f)];
        titleLabel.tag = 1; // We use the tag to set it later
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        UITextView *dataLabel = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 320.f, 150.0f)];
        dataLabel.tag = 2;
        dataLabel.font = [UIFont systemFontOfSize:14.0f];
        dataLabel.textAlignment = NSTextAlignmentLeft;
        dataLabel.backgroundColor = [UIColor clearColor];
        
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:dataLabel];
    }
    
    // Cannot select these cells
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Access labels in the cell using the tag #
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    if(indexPath.row < 2) {
        UILabel *dataLabel = (UILabel *)[cell viewWithTag:2];
        dataLabel.text = [self.rowDataArray objectAtIndex:indexPath.row];
    } else {
        UITextView *dataLabel = (UITextView *) [cell viewWithTag:2];
        dataLabel.text = [self.rowDataArray objectAtIndex:indexPath.row];
    }
    
    // Display the data in the table
    titleLabel.text = [self.rowTitleArray objectAtIndex:indexPath.row];

    return cell;
}


#pragma mark - ()

- (void)logoutButtonTouchHandler:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// Set received values if they are not nil and reload the table
- (void)updateProfileForUser: (PFUser *) user {
    /*
     self.rowTitleArray = @[@"Gender", @"Age", @"Interest1", @"Interest2", @"Interest3", @"Goals", @"Achievements", @"Organizations", @"About"];
*/
    if([user objectForKey:@"gymbudProfile"][@"gender"]) {
        [self.rowDataArray replaceObjectAtIndex:0 withObject:[user objectForKey:@"gymbudProfile"][@"gender"]];

    } else if ([user objectForKey:@"profile"][@"gender"]) {
        [self.rowDataArray replaceObjectAtIndex:0 withObject:[user objectForKey:@"profile"][@"gender"]];
    }
    
    if([user objectForKey:@"gymbudProfile"][@"age"]) {
        [self.rowDataArray replaceObjectAtIndex:1 withObject:[user objectForKey:@"gymbudProfile"][@"age"]];
        
    } else if ([user objectForKey:@"profile"][@"age"]) {
        [self.rowDataArray replaceObjectAtIndex:1 withObject:[user objectForKey:@"profile"][@"age"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"goals"]) {
        [self.rowDataArray replaceObjectAtIndex:2 withObject:[user objectForKey:@"gymbudProfile"][@"goals"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"times"]) {
        [self.rowDataArray replaceObjectAtIndex:3 withObject:[user objectForKey:@"gymbudProfile"][@"times"]];
    }
    
    [self.tableView reloadData];
    
    // Set the name in the header view label
    if([user objectForKey:@"gymbudProfile"][@"name"]) {
        self.headerNameLabel.text = [user objectForKey:@"gymbudProfile"][@"name"];
        
    } else if ([user objectForKey:@"profile"][@"name"]) {
        self.headerNameLabel.text = [user objectForKey:@"profile"][@"name"];
    }
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([user objectForKey:@"gymbudProfile"][@"profilePicture"]) {
        PFFile *theImage = [user objectForKey:@"gymbudProfile"][@"profilePicture"];
        __weak UserDetailsViewController *weakSelf = self;
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            NSLog(@"+++++++++ Loading image view with real data ++++++++");
            weakSelf.headerImageView.image = [UIImage imageWithData:data];
        }];
//        self.headerImageView.image = [UIImage imageWithData:imageData];
        // Add a nice corner radius to the image
        self.headerImageView.layer.cornerRadius = 8.0f;
        self.headerImageView.layer.masksToBounds = YES;
    } else {
        if ([user objectForKey:@"profile"][@"pictureURL"]) {
            self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            NSURL *pictureURL = [NSURL URLWithString:[user objectForKey:@"profile"][@"pictureURL"]];
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }
}

- (IBAction)headerJoinButtonPressed:(id)sender
{
    // join event from here
    PFObject *event = annotation;
    
    PFQuery *queryForEvent = [PFQuery queryWithClassName:@"Event"];
    [queryForEvent includeKey:@"organizer"];
    [queryForEvent includeKey:@"attendees"];
    [queryForEvent whereKey:@"objectId" equalTo:[event objectId]];
    
    [queryForEvent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(([objects count] == 0) || ([objects count] > 1)) {
            return;
        }
        
        // we need to create a join request for hitting the button.
        PFObject *requestObject = [PFObject objectWithClassName:@"Request"];
        [requestObject setObject:[objects objectAtIndex:0] forKey:@"event"];
        [requestObject setObject:[PFUser currentUser] forKey:@"requestor"];
        
        [requestObject saveInBackground];
        
        UIAlertView * alertView =[[UIAlertView alloc ] initWithTitle:@"Join request received"
                                                         message:@"The organizer will contact you soon"
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles: nil];
        [alertView show];
        
//        UIAlertController * alert=   [UIAlertController
//                                      alertControllerWithTitle:@"Join request received"
//                                      message:@"The organizer will contact you soon"
//                                      preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        [rootViewController presentViewController: alert animated: YES completion: nil];
        
        PFUser *organizer = [objects objectAtIndex:0][@"organizer"];
        PFPush *push = [[PFPush alloc] init];
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:organizer];
        
        NSString *name;
        PFUser *currentUser = [PFUser currentUser];
        if([currentUser objectForKey:@"gymbudProfile"][@"name"]) {
            name = [currentUser objectForKey:@"gymbudProfile"][@"name"];
        } else {
            name = [currentUser objectForKey:@"profile"][@"name"];
        }
        [push setMessage:[NSString stringWithFormat:@"%@ wants to join, accept?", name]];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSString stringWithFormat:@"%@ wants to join, accept?", name] forKey:@"alert"];
        [data setObject:[objects objectAtIndex:0] forKey:@"eventObj"];
        [data setObject:currentUser forKey:@"requestor"];
        [push setData:data];
        [push setQuery:query];
        [push sendPushInBackground];
    }];
//    [queryForEvent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if([objects count] == 0 || [objects count] > 1) {
//            return;
//        }
//        PFObject *eventObject = [objects objectAtIndex:0];
//        NSMutableArray *attendees = [eventObject objectForKey:@"attendees"];
//        if(!attendees) {
//            attendees = [[NSMutableArray alloc] init];
//        }
//        [attendees addObject:[PFUser currentUser]];
//        [eventObject setObject:attendees forKey:@"attendees"];
//        
//        PFQuery *query = [PFInstallation query];
//        
//        [query whereKey:@"user" equalTo:[eventObject objectForKey:@"organizer"]];
//        // only return Installations that belong to a User that
//        // matches the innerQuery
//        
//        // Send the notification.
//        PFPush *push = [[PFPush alloc] init];
//        [push setQuery:query];
//        
//        PFUser *currentUser = [PFUser currentUser];
//        NSString *name;
//        if([currentUser objectForKey:@"gymbudProfile"][@"name"]) {
//            name = [currentUser objectForKey:@"gymbudProfile"][@"name"];
//        } else {
//            name = [currentUser objectForKey:@"profile"][@"name"];
//        }
//        [push setMessage:[NSString stringWithFormat:@"%@ joined your event!", name]];
//        [push sendPushInBackground];
//        [eventObject saveInBackground];
//        
//        // Stitch together a postObject and send this async to Parse
//        PFObject *activityObject = [PFObject objectWithClassName:@"Activity"];
//        // Activity has the following fields:
//        /*
//         Activity
//         
//         fromUser : User
//         toUser : User
//         type : String
//         content : String
//         */
//        [activityObject setObject:[eventObject objectForKey:@"organizer"] forKey:@"fromUser"];
//        [activityObject setObject:currentUser forKey:@"toUser"];
//        [activityObject setObject:@"message" forKey:@"type"];
//        [activityObject setObject:@"You joined my event. Let's go lift!" forKey:@"content"];
//        [activityObject setObject:[NSNumber numberWithBool:YES] forKey:@"unread"];
//        [activityObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                NSLog(@"Couldn't save!");
//                NSLog(@"%@", error);
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                [alertView show];
//                return;
//            }
//            if (succeeded) {
//                NSLog(@"Successfully saved!");
//                NSLog(@"%@", activityObject);
//                //            dispatch_async(dispatch_get_main_queue(), ^{
//                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePostNotification" object:nil];
//                //            });
//            } else {
//                NSLog(@"Failed to save.");
//            }
//        }];
//        
//        PFQuery *innerQuery = [PFUser query];
//        
//        [innerQuery whereKey:@"username" equalTo:[currentUser objectForKey:@"username"]];
//        NSLog(@"about to push");
//        
//        NSLog(@"%@", innerQuery);
//        PFQuery *query2 = [PFInstallation query];
//        
//        // only return Installations that belong to a User that
//        // matches the innerQuery
//        [query2 whereKey:@"user" matchesQuery:innerQuery];
//        
//        // Send the notification.
//        PFPush *push2 = [[PFPush alloc] init];
//        [push2 setQuery:query2];
//        
//        NSString *name2;
//        if([[eventObject objectForKey:@"organizer"] objectForKey:@"gymbudProfile"][@"name"]) {
//            name2 = [[eventObject objectForKey:@"organizer"] objectForKey:@"gymbudProfile"][@"name"];
//        } else {
//            name2 = [[eventObject objectForKey:@"organizer"] objectForKey:@"profile"][@"name"];
//        }
//        [push2 setMessage:[NSString stringWithFormat:@"Message From: %@", name2]];
//        [push2 sendPushInBackground];
//    }];
    self.headerJoinButton.enabled = NO;
    [self.headerJoinButton setHidden:YES];
}

@end
