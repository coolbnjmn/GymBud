//
//  EventDetailsTableViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 12/17/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "EventDetailsTableViewController.h"
#import "GymBudConstants.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "MapViewAnnotation.h"
#import "GymBudFriendDetailsTableViewController.h"

#define kCellHeight 70;

@interface EventDetailsTableViewController ()
@property (nonatomic, strong) NSArray* listOfSectionNames;
@end

@implementation EventDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Event Details";
    NSLog(@"object is %@", self.objectList);
    self.tableView.backgroundColor = kGymBudLightBlue;
    self.listOfSectionNames = @[@"Organizer Information", @"Excercise Types", @"Time Information", @"Location Information", @"Confirmed Attendees"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:  // Event Organizer
            return 1;
            break;
        case 1: // Body Parts
            return 1;
            break;
        case 2: // Duration time and length
            return 1;
            break;
        case 3: // Location address and map
            return 2;
            break;
        case 4: // attendees
        {
            NSArray *attendees = [self.objectList objectForKey:@"attendees"];
            if (![attendees count])
                return 1;
            else
                return [attendees count];
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return kCellHeight;
    }
    else if (indexPath.section == 1)
        return 60;
    else if (indexPath.section == 2)
        return 60;
    else if (indexPath.section == 3 && indexPath.row == 0)
        return 80;
    else if (indexPath.section == 3 && indexPath.row == 1)
        return 267;
    else
        return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 40)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string =[self.listOfSectionNames objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:string];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"MagistralATT" size:20];
    label.textColor = [UIColor whiteColor];

    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 50;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        case 0:  // Organizer name
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
            cell.imageView.image = [UIImage imageNamed:@"yogaIcon.png"];
            cell.imageView.layer.cornerRadius = 30.0f;
            cell.imageView.layer.masksToBounds = YES;
            CGSize itemSize = CGSizeMake(60, 60);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [cell.imageView.image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            PFFile *theImage = [self.objectList objectForKey:@"organizer"][@"gymbudProfile"][@"profilePicture"];
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
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.objectList objectForKey:@"organizer"][@"gymbudProfile"][@"name"]];
            cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:16];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.numberOfLines = 1;
            
            [cell.textLabel sizeToFit];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.detailTextLabel.text = @"";
        }
        break;
            
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"body" forIndexPath:indexPath];
            NSArray *subLogoIndices = [self.objectList objectForKey:@"detailLogoIndices"];
            if (![subLogoIndices count])
            {
                UILabel *nobody = (UILabel*)[cell viewWithTag:5];
                nobody.text = @"No Excercise Type Specified";
                nobody.font = [UIFont fontWithName:@"MagistralATT" size:16];
                nobody.textColor = [UIColor whiteColor];
                nobody.adjustsFontSizeToFitWidth = YES;
                nobody.numberOfLines = 1;
            }
            else
            {
                int subLogoIndex = 0;
                for(NSNumber *index in subLogoIndices)
                {
                    if(subLogoIndex == 0) {
                        
                        UIImageView *imv = (UIImageView*) [cell viewWithTag:1];
                        imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
                        [cell.contentView addSubview:imv];
                    } else if(subLogoIndex == 1) {
                        UIImageView *imv = (UIImageView*) [cell viewWithTag:2];
                        imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
                        [cell.contentView addSubview:imv];
                    } else if(subLogoIndex == 2) {
                        UIImageView *imv = (UIImageView*) [cell viewWithTag:3];
                        imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
                        [cell.contentView addSubview:imv];
                    } else {
                        UIImageView *imv = (UIImageView*) [cell viewWithTag:4];
                        imv.image=[UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:[index integerValue]]];
                        [cell.contentView addSubview:imv];
                    }
                    subLogoIndex++;
                }
            }

        }
        break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
            if (indexPath.row == 0)
            {
                NSNumber *duration= [self.objectList objectForKey:@"duration"];
                NSDate *time = [self.objectList objectForKey:@"time"];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMMM dd yyyy"];
                NSString *theDate = [dateFormat stringFromDate:time];

                cell.textLabel.text = [NSString stringWithFormat:@"Date: %@", theDate];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Duration: %@", duration];
                cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:16];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.font = [UIFont fontWithName:@"MagistralATT" size:12];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            }
            
        }
        break;
        case 3:
        {
            if (indexPath.row == 0)
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
                cell.textLabel.text = [self.objectList objectForKey:@"locationName"];
                cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:16];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.numberOfLines = 2;
                cell.detailTextLabel.text = @"";
            }
            else
            {
                PFGeoPoint *data = [self.objectList objectForKey:@"location"];
                NSLog(@"lat is %f and long is %f", [data latitude], [data longitude]);
                cell = [tableView dequeueReusableCellWithIdentifier:@"map" forIndexPath:indexPath];
                MKMapView *map = (MKMapView*)[cell viewWithTag:6];
                //Takes a center point and a span in miles (converted from meters using above method)
                CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake([data latitude], [data longitude]);
                MKCoordinateRegion adjustedRegion = [map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 1609.344f* (0.5f), 1609.344f* (0.5f))];
                
                [map setRegion:adjustedRegion animated:YES];

                MapViewAnnotation *annotation = [[MapViewAnnotation alloc] initWithTitle:[self.objectList objectForKey:@"locationName"] AndCoordinate:startCoord];
                [map addAnnotation:annotation];
            }
        }
        break;
        case 4:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
            NSArray *attendees = [self.objectList objectForKey:@"attendees"];
            PFUser *user = ([[self.objectList objectForKey:@"attendees"][indexPath.row] isKindOfClass:[PFUser class]] ? [self.objectList objectForKey:@"attendees"][indexPath.row] : nil);
            PFObject *contact;

            if(!user) {
                contact = [self.objectList objectForKey:@"attendees"][indexPath.row];
            }
            [user fetchIfNeeded];
            if (![attendees count])
                cell.textLabel.text = @"No attendees have joined this event";
            else
            {
                if(!user) {
                    [contact fetch];
                    cell.textLabel.text = [NSString stringWithFormat:@"%@",contact[@"name"]];
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@",user[@"profile"][@"name"]];
                }
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:16];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.imageView.image = nil; //[UIImage imageNamed:@"yogaIcon.png"];
        }

        default:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
            cell.textLabel.text= @"";
        }
            break;
    }
    cell.backgroundColor = kGymBudLightBlue;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (bool) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath.section == 0) {
        return YES;
    } else return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"about to segue");
    GymBudFriendDetailsTableViewController *dest = (GymBudFriendDetailsTableViewController*)[segue destinationViewController];
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    dest.user = [self.objectList objectForKey:@"organizer"];

//    [dest setUser:[self.objects objectAtIndex:indexPath.row]];
}


@end
