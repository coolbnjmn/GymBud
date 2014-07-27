#import "UserDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PAWPost.h"
#import "MessageUserVC.h"

@implementation UserDetailsViewController
@synthesize annotation;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Profile";
    self.tableView.backgroundColor = [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithTitle:@"Message User" style:UIBarButtonItemStyleBordered target:self action:@selector(messageUser:)];
    self.navigationItem.rightBarButtonItem = messageButton;
    
    // Load table header view from nib
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;
    
    // Create array for table row titles
    self.rowTitleArray = @[@"Location", @"Gender", @"Date of Birth", @"Relationship", @"Interest1", @"Interest2", @"Interest3", @"Background", @"Achievements", @"Goals"];
    
    // Set default values for the table row data
    self.rowDataArray = [@[@"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A"] mutableCopy];
    
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
//    if ([PFUser currentUser]) {
//        [self updateProfile];
//    }
    NSLog(@"annotation is: ");
    NSLog(@"%@", annotation);
    PAWPost *post = (PAWPost *) annotation;
    if([post user]) {
        [[post user] fetchIfNeeded];
        [self updateProfileForUser: [post user]];
    }
    
    UIImage *pictureLogo;
    if([post.activity isEqualToString:@"Aerobics"]) {
        pictureLogo = [UIImage imageNamed:@"aerobicsIcon.png"];
    } else if([post.activity isEqualToString:@"Basketball"]) {
        pictureLogo = [UIImage imageNamed:@"basketballIcon.png"];
    } else if([post.activity isEqualToString:@"Crossfit"]) {
        pictureLogo = [UIImage imageNamed:@"crossfitIcon.png"];
    } else if([post.activity isEqualToString:@"Running"]) {
        pictureLogo = [UIImage imageNamed:@"runningIcon.png"];
    } else if([post.activity isEqualToString:@"Swimming"]) {
        pictureLogo = [UIImage imageNamed:@"swimmingIcon.png"];
    } else if([post.activity isEqualToString:@"Weightlifting"]) {
        pictureLogo = [UIImage imageNamed:@"weightliftingIcon.png"];
    } else {
        pictureLogo = [UIImage imageNamed:@"yogaIcon.png"];
    }
    self.headerPictureLogo.image = pictureLogo;
    self.headerCheckinMessage.text = post.title;
}

-(void)messageUser:(id) sender {
    // about to message user
    PAWPost *post = (PAWPost *) annotation;

    NSLog(@"about to message user");
    MessageUserVC *controller = [[MessageUserVC alloc] initWithNibName:nil bundle:nil];
    controller.user = [post user];
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
    if(indexPath.row < 7) {
        return 44.0f;
    } else {
        return 180.0f;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *BigCellIdentifier = @"BigCell";
    
    UITableViewCell *cell;
    if(indexPath.row < 7) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:BigCellIdentifier];
    }
    
    if (cell == nil && indexPath.row < 7) {
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
    if(indexPath.row < 7) {
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
    if ([user objectForKey:@"profile"][@"location"]) {
        [self.rowDataArray replaceObjectAtIndex:0 withObject:[user objectForKey:@"profile"][@"location"]];
    }
    
    if ([user objectForKey:@"profile"][@"gender"]) {
        [self.rowDataArray replaceObjectAtIndex:1 withObject:[user objectForKey:@"profile"][@"gender"]];
    }
    
    if ([user objectForKey:@"profile"][@"birthday"]) {
        [self.rowDataArray replaceObjectAtIndex:2 withObject:[user objectForKey:@"profile"][@"birthday"]];
    }
    
    if ([user objectForKey:@"profile"][@"relationship"]) {
        [self.rowDataArray replaceObjectAtIndex:3 withObject:[user objectForKey:@"profile"][@"relationship"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest1"]) {
        [self.rowDataArray replaceObjectAtIndex:4 withObject:[user objectForKey:@"gymbudProfile"][@"interest1"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest2"]) {
        [self.rowDataArray replaceObjectAtIndex:5 withObject:[user objectForKey:@"gymbudProfile"][@"interest2"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest3"]) {
        [self.rowDataArray replaceObjectAtIndex:6 withObject:[user objectForKey:@"gymbudProfile"][@"interest3"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"background"]) {
        [self.rowDataArray replaceObjectAtIndex:7 withObject:[user objectForKey:@"gymbudProfile"][@"background"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"achievements"]) {
        [self.rowDataArray replaceObjectAtIndex:8 withObject:[user objectForKey:@"gymbudProfile"][@"achievements"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"goals"]) {
        [self.rowDataArray replaceObjectAtIndex:9 withObject:[user objectForKey:@"gymbudProfile"][@"goals"]];
    }
    [self.tableView reloadData];
    
    // Set the name in the header view label
    if ([user objectForKey:@"profile"][@"name"]) {
        self.headerNameLabel.text = [user objectForKey:@"profile"][@"name"];
    }
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([user objectForKey:@"profile"][@"pictureURL"]) {
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

// Set received values if they are not nil and reload the table
- (void)updateProfile {
    if ([[PFUser currentUser] objectForKey:@"profile"][@"location"]) {
        [self.rowDataArray replaceObjectAtIndex:0 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"location"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"gender"]) {
        [self.rowDataArray replaceObjectAtIndex:1 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"gender"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"birthday"]) {
        [self.rowDataArray replaceObjectAtIndex:2 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"birthday"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"relationship"]) {
        [self.rowDataArray replaceObjectAtIndex:3 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"relationship"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"interest1"]) {
        [self.rowDataArray replaceObjectAtIndex:4 withObject:[[PFUser currentUser] objectForKey:@"gymbudProfile"][@"interest1"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"interest2"]) {
        [self.rowDataArray replaceObjectAtIndex:5 withObject:[[PFUser currentUser] objectForKey:@"gymbudProfile"][@"interest2"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"interest3"]) {
        [self.rowDataArray replaceObjectAtIndex:6 withObject:[[PFUser currentUser] objectForKey:@"gymbudProfile"][@"interest3"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"background"]) {
        [self.rowDataArray replaceObjectAtIndex:7 withObject:[[PFUser currentUser] objectForKey:@"gymbudProfile"][@"background"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"achievements"]) {
        [self.rowDataArray replaceObjectAtIndex:8 withObject:[[PFUser currentUser] objectForKey:@"gymbudProfile"][@"achievements"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"goals"]) {
        [self.rowDataArray replaceObjectAtIndex:9 withObject:[[PFUser currentUser] objectForKey:@"gymbudProfile"][@"goals"]];
    }
    [self.tableView reloadData];
    
    // Set the name in the header view label
    if ([[PFUser currentUser] objectForKey:@"profile"][@"name"]) {
        self.headerNameLabel.text = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
    }
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]];
        
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

@end
