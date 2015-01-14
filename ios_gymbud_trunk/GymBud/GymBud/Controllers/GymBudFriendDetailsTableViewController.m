//
//  GymBudFriendDetailsTableViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 1/14/15.
//  Copyright (c) 2015 GymBud. All rights reserved.
//

#import "GymBudFriendDetailsTableViewController.h"
#import "GymBudConstants.h"

@interface GymBudFriendDetailsTableViewController ()

@end

@implementation GymBudFriendDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = kGymBudLightBlue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section== 0)
        return 1;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 110;
    else
        return 80;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
        return 1.0f;
    else
        return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = kGymBudLightBlue;
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"MagistralATT" size:18];
    sectionHeader.textColor = [UIColor whiteColor];
    
    switch(section) {
        case 1:sectionHeader.text = @"Personal Preferences"; break;
        default:sectionHeader.text = @""; break;
    }
    return sectionHeader;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"headerrow" forIndexPath:indexPath];
    else if (indexPath.section == 1 && indexPath.row == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"inputtext" forIndexPath:indexPath];
    else if (indexPath.section == 1 && indexPath.row == 1)
        cell = [tableView dequeueReusableCellWithIdentifier:@"inputtext_cell2" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"commonrow" forIndexPath:indexPath];
    // Configure the cell...
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                // update image row
                UIImageView *img = (UIImageView*)[cell viewWithTag:1];
                img.image = [UIImage imageNamed:@"yogaIcon.png"];
                img.layer.cornerRadius = 36.0f;
                img.layer.masksToBounds = YES;

                if ([self.user objectForKey:@"gymbudProfile"][@"profilePicture"])
                {
                    PFFile *theImage = [self.user objectForKey:@"gymbudProfile"][@"profilePicture"];
                    NSLog(@"the image %@", theImage);
                    __weak UITableViewCell *weakCell = cell;
                    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                        NSLog(@"+++++++++ Loading image view with real data ++++++++");
                        UIImageView *img = (UIImageView*)[weakCell viewWithTag:1];
                        if (![UIImage imageWithData:data])
                        {
                            img.image = [UIImage imageNamed:@"yogaIcon.png"];
                        }
                        else
                        {
                            img.image = [UIImage imageWithData:data];
                        }
                        NSLog(@"image is %@", weakCell.imageView.image);
                    }];
                }
                
                UILabel *label = (UILabel*)[cell viewWithTag:2];
                
                UILabel *label_gender = (UILabel*)[cell viewWithTag:3];
                if (self.user[@"gymbudProfile"])
                {
                    label.text = self.user[@"gymbudProfile"][@"name"];

                    if ([self.user[@"gymbudProfile"][@"age"] length] > 0 && [self.user[@"gymbudProfile"][@"gender"] length] > 0)
                        label_gender.text = [NSString stringWithFormat:@"Age: %@, Gender: %@", self.user[@"gymbudProfile"][@"age"], self.user[@"gymbudProfile"][@"gender"]];
                    else if ([self.user[@"gymbudProfile"][@"age"] length] > 0)
                        label_gender.text = [NSString stringWithFormat:@"Age: %@", self.user[@"gymbudProfile"][@"age"]];
                    else if ([self.user[@"gymbudProfile"][@"gender"] length] > 0)
                        label_gender.text = [NSString stringWithFormat:@"Gender: %@", self.user[@"gymbudProfile"][@"gender"]];
                }
                else
                {
                    label.text = self.user[kFacebookUsername];
                    if ([self.user[@"profile"][@"age"] length] > 0 && [self.user[@"profile"][@"gender"] length] > 0)
                        label_gender.text = [NSString stringWithFormat:@"Age: %@, Gender: %@", self.user[@"profile"][@"age"], self.user[@"profile"][@"gender"]];
                    else if ([self.user[@"profile"][@"age"] length] > 0)
                        label_gender.text = [NSString stringWithFormat:@"Age: %@", self.user[@"profile"][@"age"]];
                    else if ([self.user[@"profile"][@"gender"] length] > 0)
                        label_gender.text = [NSString stringWithFormat:@"Gender: %@", self.user[@"profile"][@"gender"]];


                }
                label.textColor = [UIColor whiteColor];
                label_gender.textColor = [UIColor whiteColor];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row==0)
            {
                UITextView *tv = (UITextView*)[cell viewWithTag:5];
                tv.editable = NO;
                if ([[self.user objectForKey:@"gymbudProfile"][@"goals"] length] > 0)
                {
                    tv.text = [self.user objectForKey:@"gymbudProfile"][@"goals"];
                    tv.textColor = [UIColor blackColor];
                    
                }
                else
                {
                    tv.text = @"No goals specified";
                    tv.textColor = [UIColor lightGrayColor];
                }
                tv.backgroundColor = kGymBudLightBlue;
            }
            else if (indexPath.row==1)
            {
                UITextView *tv = (UITextView*)[cell viewWithTag:6];
                if ([[self.user objectForKey:@"gymbudProfile"][@"times"] length] > 0)
                {
                    tv.text = [self.user objectForKey:@"gymbudProfile"][@"times"];
                    tv.textColor = [UIColor blackColor];
                }
                else
                {
                    tv.text = @"No preferred times specified.";
                    tv.textColor = [UIColor lightGrayColor];
                }
                tv.backgroundColor = kGymBudLightBlue;
                cell.tag = 20;
            }
            
        }
            
        default:
            break;
    }
    cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"MagistralATT" size:12];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIColor * color = kGymBudLightBlue;
    cell.backgroundColor = color;
    
    
    return cell;
}

@end
