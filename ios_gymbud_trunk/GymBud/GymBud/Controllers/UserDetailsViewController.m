#import "UserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GymBudEventModel.h"
#import "MessageUserVC.h"
#import "GymBudConstants.h"

@implementation UserDetailsViewController
@synthesize annotation;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Organizer";
    self.tableView.backgroundColor = [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithTitle:@"Message User" style:UIBarButtonItemStyleBordered target:self action:@selector(messageUser:)];
    self.navigationItem.rightBarButtonItem = messageButton;
    
    // Load table header view from nib
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;
    
    // Create array for table row titles
    self.rowTitleArray = @[@"Gender", @"Age", @"Interest1", @"Interest2", @"Interest3", @"Goals", @"Achievements", @"Organizations", @"About"];
    
    // Set default values for the table row data
    self.rowDataArray = [@[@"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A"] mutableCopy];
    
    NSLog(@"annotation is: ");
    NSLog(@"%@", annotation);
    GymBudEventModel *event = (GymBudEventModel *) annotation;
    if([event organizer]) {
        [[event organizer] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error){
            [self updateProfileForUser:(PFUser *)object];
        }];
    }
    
    if([event attendees]) {
        for(PFUser *attendee in [event attendees]) {
            if([[attendee objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                self.headerJoinButton.hidden = YES;
                break;
            }
        }
    }
    UIImage *pictureLogo = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:event.activity]];

    self.headerPictureLogo.image = pictureLogo;
    self.headerCheckinMessage.text = [[event.title stringByAppendingString:@". "] stringByAppendingString:event.eventDescription];
}

-(void)messageUser:(id) sender {
    // about to message user
    GymBudEventModel *event = (GymBudEventModel *) annotation;

    NSLog(@"about to message user");
    MessageUserVC *controller = [[MessageUserVC alloc] initWithNibName:nil bundle:nil];
    controller.user = [event organizer];
    [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.rowTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < 5) {
        return 44.0f;
    } else {
        return 180.0f;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *BigCellIdentifier = @"BigCell";
    
    UITableViewCell *cell;
    if(indexPath.row < 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:BigCellIdentifier];
    }
    
    if (cell == nil && indexPath.row < 5) {
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
    if(indexPath.row < 5) {
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
    
    if ([user objectForKey:@"gymbudProfile"][@"interest1"]) {
        [self.rowDataArray replaceObjectAtIndex:2 withObject:[user objectForKey:@"gymbudProfile"][@"interest1"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest2"]) {
        [self.rowDataArray replaceObjectAtIndex:3 withObject:[user objectForKey:@"gymbudProfile"][@"interest2"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest3"]) {
        [self.rowDataArray replaceObjectAtIndex:4 withObject:[user objectForKey:@"gymbudProfile"][@"interest3"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"goals"]) {
        [self.rowDataArray replaceObjectAtIndex:5 withObject:[user objectForKey:@"gymbudProfile"][@"goals"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"achievements"]) {
        [self.rowDataArray replaceObjectAtIndex:6 withObject:[user objectForKey:@"gymbudProfile"][@"achievements"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"organizations"]) {
        [self.rowDataArray replaceObjectAtIndex:7 withObject:[user objectForKey:@"gymbudProfile"][@"organizations"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"about"]) {
        [self.rowDataArray replaceObjectAtIndex:8 withObject:[user objectForKey:@"gymbudProfile"][@"about"]];
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
    GymBudEventModel *event = (GymBudEventModel *) annotation;
    
    PFQuery *queryForEvent = [PFQuery queryWithClassName:@"Event"];
    [queryForEvent includeKey:@"organizer"];
    [queryForEvent includeKey:@"attendees"];
    [queryForEvent whereKey:@"time" equalTo:event.eventDate];
    [queryForEvent whereKey:@"duration" equalTo:event.duration];
    [queryForEvent whereKey:@"activity" equalTo:event.activity];
    [queryForEvent whereKey:@"count" equalTo:event.count];
    [queryForEvent whereKey:@"organizer" equalTo:event.organizer];
    if(![event.eventDescription isEqualToString:@"No Description Provided"]) {
        [queryForEvent whereKey:@"description" equalTo:event.eventDescription];
    }
    
    [queryForEvent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] == 0 || [objects count] > 1) {
            return;
        }
        PFObject *eventObject = [objects objectAtIndex:0];
        NSMutableArray *attendees = [eventObject objectForKey:@"attendees"];
        if(!attendees) {
            attendees = [[NSMutableArray alloc] init];
        }
        [attendees addObject:[PFUser currentUser]];
        [eventObject setObject:attendees forKey:@"attendees"];
        [eventObject saveInBackground];
    }];
    NSLog(@"attendees: %@", event.attendees);
    self.headerJoinButton.enabled = NO;
    [self.headerJoinButton setHidden:YES];
}

@end
