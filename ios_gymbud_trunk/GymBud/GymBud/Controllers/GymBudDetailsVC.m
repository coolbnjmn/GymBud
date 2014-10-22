//
//  GymBudDetailsVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 9/30/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudDetailsVC.h"
#import "GymBudConstants.h"

@interface GymBudDetailsVC ()

@property (nonatomic, strong) NSArray *mutualFriends;
@end

@implementation GymBudDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"GymBudHeaderView" owner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;

    // Create array for table row titles
    self.rowTitleArray = @[@"Interest1", @"Interest2", @"Interest3", @"Goals", @"Achievements", @"Organizations", @"About"];
    
    // Set default values for the table row data
    self.rowDataArray = [@[@"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A", @"N/A"] mutableCopy];
    
    if(self.user[@"gymbudProfile"]) {
        self.text1Label.text = self.user[@"gymbudProfile"][@"name"];
        self.text2Label.text = [@"Gender: " stringByAppendingString:self.user[@"gymbudProfile"][@"gender"]];
        self.text3Label.text = [@"Age: " stringByAppendingString:self.user[@"gymbudProfile"][@"age"]];
    } else {
        self.text1Label.text = self.user[kFacebookUsername];
        self.text2Label.text = [@"Gender: " stringByAppendingString:self.user[@"profile"][@"gender"]];
        if(self.user[@"profile"][@"birthday"]) {
            self.text3Label.text = [@"Age: " stringByAppendingString:self.user[@"profile"][@"birthday"]];
        } else {
            self.text3Label.text = @"No Birthday Found";
        }
    }
    [self updateProfileForUser:self.user];
    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([self.user objectForKey:@"gymbudProfile"][@"profilePicture"]) {
        PFFile *theImage = [self.user objectForKey:@"gymbudProfile"][@"profilePicture"];
        __weak GymBudDetailsVC *weakSelf = self;
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            NSLog(@"+++++++++ Loading image view with real data ++++++++");
            weakSelf.headerImageView.image = [UIImage imageWithData:data];
        }];
        //        self.headerImageView.image = [UIImage imageWithData:imageData];
        // Add a nice corner radius to the image
        self.headerImageView.layer.cornerRadius = 8.0f;
        self.headerImageView.layer.masksToBounds = YES;
    } else {
        if ([self.user objectForKey:@"profile"][@"pictureURL"]) {
            self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            NSURL *pictureURL = [NSURL URLWithString:[self.user objectForKey:@"profile"][@"pictureURL"]];
            
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
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"context.fields(mutual_friends)", @"fields",
                            nil
                            ];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", self.user[@"profile"][@"facebookId"]]
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              self.mutualFriends = result[@"context"][@"mutual_friends"][@"data"];
                              [self.tableView reloadData];
                          }];
    
    self.text1Label.textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    self.text2Label.textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    self.text3Label.textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];

    self.headerView.backgroundColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
    
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) {
        return self.mutualFriends.count;
    } else {
        return self.rowTitleArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Mutual GymBuds";
    } else {
        return @"Profile";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1) {
        if(indexPath.row < 3) {
            return 44.0f;
        } else {
            return 180.0f;
        }
    } else {
        return 44.0f;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *BigCellIdentifier = @"BigCell";
    
    UITableViewCell *cell;
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = [self.mutualFriends objectAtIndex:indexPath.row][@"name"];
        return cell;
    }
    
    // only get here if we are in section == 1
    if(indexPath.row < 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:BigCellIdentifier];
    }
    
    if (cell == nil && indexPath.row < 3) {
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
    if(indexPath.row < 3) {
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

// Set received values if they are not nil and reload the table
- (void)updateProfileForUser: (PFUser *) user {
    /*
     self.rowTitleArray = @[@"Gender", @"Age", @"Interest1", @"Interest2", @"Interest3", @"Goals", @"Achievements", @"Organizations", @"About"];
     */
    if ([user objectForKey:@"gymbudProfile"][@"interest1"]) {
        [self.rowDataArray replaceObjectAtIndex:0 withObject:[user objectForKey:@"gymbudProfile"][@"interest1"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest2"]) {
        [self.rowDataArray replaceObjectAtIndex:1 withObject:[user objectForKey:@"gymbudProfile"][@"interest2"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"interest3"]) {
        [self.rowDataArray replaceObjectAtIndex:2 withObject:[user objectForKey:@"gymbudProfile"][@"interest3"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"goals"]) {
        [self.rowDataArray replaceObjectAtIndex:3 withObject:[user objectForKey:@"gymbudProfile"][@"goals"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"achievements"]) {
        [self.rowDataArray replaceObjectAtIndex:4 withObject:[user objectForKey:@"gymbudProfile"][@"achievements"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"organizations"]) {
        [self.rowDataArray replaceObjectAtIndex:5 withObject:[user objectForKey:@"gymbudProfile"][@"organizations"]];
    }
    
    if ([user objectForKey:@"gymbudProfile"][@"about"]) {
        [self.rowDataArray replaceObjectAtIndex:6 withObject:[user objectForKey:@"gymbudProfile"][@"about"]];
    }
    [self.tableView reloadData];
    
    
}

@end
