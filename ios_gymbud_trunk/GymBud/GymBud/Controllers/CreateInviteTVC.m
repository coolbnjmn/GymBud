//
//  CreateInviteTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/10/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "CreateInviteTVC.h"
#import "GoActivityCVCell.h"
#import "GymBudConstants.h"
#import "CreateInviteCVCCell.h"
#import "LocationFinderVC.h"
#import "InviteFriendsTVC.h"
#import <UIAlertView+Blocks.h>
#import <AFNetworking/AFNetworking.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"


@interface CreateInviteTVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, LocationFinderVCDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *section2Label;
@property (weak, nonatomic) IBOutlet UITextField *section3TextField;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (nonatomic, strong) NSMutableArray *selectedBodyParts;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *date;

@end

@implementation CreateInviteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Create Event";
    self.selectedBodyParts = [[NSMutableArray alloc] initWithCapacity:[kGBBodyPartArray count]];
    self.tableView.backgroundColor = kGymBudGrey;
    self.tableView.alwaysBounceVertical = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 6)];
    headerView.backgroundColor = kGymBudOrange;
    return headerView;
    
    //    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 3) {
        return 6.0f;
    } else {
        return CGFLOAT_MIN;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 3;
            break;
            
        default:
            return 0;
            break;
    };
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 1)
        return 140;
    else
        return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"date"
                                                        forIndexPath:indexPath];
            cell.backgroundColor = kGymBudGrey;
            self.section3TextField = (UITextField*)[cell viewWithTag:100];
            
            self.section3TextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            self.section3TextField.text = @"Select a date & time";
            self.section3TextField.textAlignment = NSTextAlignmentCenter;
            self.section3TextField.textColor = kGymBudLightBlue;
            self.section3TextField.font = [UIFont fontWithName:@"MagistralATT" size:20];
            self.section3TextField.backgroundColor = kGymBudGrey;
            
            self.datePicker = [[UIDatePicker alloc] init];
            self.datePicker.minimumDate = [NSDate date];
            self.datePicker.minuteInterval = 15;
            
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSDateComponents *components = [calendar components:NSYearCalendarUnit
                                            | NSMonthCalendarUnit | NSDayCalendarUnit
                                                       fromDate:[NSDate date]];
            components.day += 5;
            NSDate *date = [calendar dateFromComponents:components];
            self.datePicker.maximumDate = date;
            self.section3TextField.delegate = self;
            self.datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            
            // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view...
            // Prepare done button
            UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
            keyboardDoneButtonView.barStyle = UIBarStyleBlack;
            keyboardDoneButtonView.translucent = YES;
            keyboardDoneButtonView.tintColor = nil;
            [keyboardDoneButtonView sizeToFit];
            
            UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                           style:UIBarButtonItemStyleBordered target:self
                                                                          action:@selector(doneClicked:)];
            [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
            
            // Plug the keyboardDoneButtonView into the text field...
            self.section3TextField.inputAccessoryView = keyboardDoneButtonView;
            self.section3TextField.inputView = self.datePicker;
            
            self.section3TextField.frame = CGRectMake(5, 5, self.view.frame.size.width-5, 55);
            
        }
            break;

        case 1:
            switch(indexPath.row) {
//                case 0:
//                    cell = [self.tableView dequeueReusableCellWithIdentifier:@"base"
//                                                                forIndexPath:indexPath];
//                    cell.textLabel.text = @"Select Up To 4 Body Parts";
//                    break;
                case 0: // Collection View
                    cell = [[CreateInviteCVCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"goActivityCell"];
                    [(CreateInviteCVCCell *)cell setCollectionViewDataSourceDelegate:self index:0];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"base"
                                                        forIndexPath:indexPath];
            // Location Cell
            if ([self.section2Label.text length] >0)
                cell.textLabel.text = self.section2Label.text;
            else
                cell.textLabel.text = @"Select a location";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = kGymBudGrey;
            break;
        
        case 3:
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"base"
                                                        forIndexPath:indexPath];

            cell.backgroundColor = kGymBudGrey;
            cell.textLabel.textColor = kGymBudLightBlue;
            cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:20];
            switch (indexPath.row)
        {
                case 0:
                    cell.textLabel.text = @"Invite Friends (SMS)";
                    cell.textLabel.textAlignment=NSTextAlignmentCenter;
                cell.backgroundColor = kGymBudLightBlue;
                cell.textLabel.textColor = kGymBudGrey;
                    break;
            case 1:
                cell.textLabel.text = @"Create an Event (Public)";
                cell.textLabel.textAlignment=NSTextAlignmentCenter;
                cell.backgroundColor = kGymBudGrey;
                break;
            case 2:
                cell.textLabel.text = @"Find Others";
                cell.textLabel.textAlignment=NSTextAlignmentCenter;
                cell.backgroundColor = kGymBudLightBlue;
                cell.textLabel.textColor = kGymBudGrey;
                break;
                
                default:
                    break;
            }
        default:
            break;
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
            [self setDateClicked:self];
            break;
        case 2:
            // Location Cell
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LocationFinderVC"
                                                                 bundle:[NSBundle mainBundle]];
            LocationFinderVC *locationFinder = [storyboard instantiateViewControllerWithIdentifier:@"LocationFinderVC"];            [self.navigationController pushViewController:locationFinder animated:YES];
            locationFinder.delegate = self;
            if(![self.section2Label.text isEqualToString:@"Select a location"]) {
                locationFinder.input = self.section2Label.text;
            }
        }
            break;
        case 3:
            switch(indexPath.row) {
                case 0: // Invite Friends button
                    [self button1Pressed:nil];
                    break;
                case 1: // Create event button
                    [self button2Pressed:nil];
                    break;
                case 2: // Find others button
                    [self button3Pressed:nil];
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

// When the setDate button is clicked, call:

- (void)setDateClicked:(id)sender {
    [self.section3TextField becomeFirstResponder];
}

- (void)doneClicked:(id)sender {
    // Write out the date...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    //Optionally for time zone conversions
    
    self.date = self.datePicker.date;
    NSString *stringFromDate = [formatter stringFromDate:self.datePicker.date];

    self.section3TextField.text = stringFromDate;
    [self.section3TextField resignFirstResponder];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [kGBBodyPartArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoActivityCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goActivityCell" forIndexPath:indexPath];
    
    if([self.selectedBodyParts containsObject:indexPath]) {
        cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:indexPath.row]];
    } else {
        cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:indexPath.row]];
    }
    cell.goActivityTextLabel.text = [kGBBodyPartArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.goActivityTextLabel.font = [UIFont fontWithName:@"MagistralA-Bold" size:18];
    cell.goActivityTextLabel.textColor = kGymBudGold;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedBodyParts count] < 4) {
        [self.selectedBodyParts addObject:indexPath];
        GoActivityCVCell *cell = (GoActivityCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:indexPath.row]];
        
    } else {
        // DO nothing, we don't want to select more than 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select up to 4 Body Parts" message:@"You have tried to select more than 4" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedBodyParts removeObject:indexPath];
    GoActivityCVCell *cell = (GoActivityCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor clearColor];
    cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:indexPath.row]];
}

- (void)didSetLocation:(NSString *)locationName {
    self.section2Label = [[UILabel alloc]init];
    self.section2Label.text = [[NSString alloc] initWithString:locationName];
    [self.tableView reloadData];
}
- (IBAction)button1Pressed:(id)sender {
    // Invite friends here
//    NSLog(@"button1Pressed");
    InviteFriendsTVC *invite = [[InviteFriendsTVC alloc] init];
    invite.date = self.date;
    invite.location = self.section2Label.text;
    invite.bodyParts = self.selectedBodyParts;
    [self.navigationController pushViewController:invite animated:YES];
    
}
- (IBAction)button2Pressed:(id)sender {
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel" action:^{
    }];
    
    RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Create" action:^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        NSString *shortDate = [formatter stringFromDate:self.date];
        
        // now for the location
        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/"];
        NSLog(@"%@", [[self.section2Label.text stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]);
        NSDictionary *params = @{@"address" : [[self.section2Label.text stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 @"sensor" : @"true",
                                 @"key" : kGoogleApiKey};
        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
            NSString *latStr;
            NSString *lngStr;
            for(id object in responseObject[@"results"]) {
                NSLog(@"%@", object);
                if([object objectForKey:@"geometry"]) {
                    latStr = object[@"geometry"][@"location"][@"lat"];
                    lngStr = object[@"geometry"][@"location"][@"lng"];
                }
            }
            
            CLLocationDegrees lat = [latStr doubleValue];
            CLLocationDegrees lng = [lngStr doubleValue];
            
            if(lat == 0 || lng == 0) {
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                lat = appDelegate.currentLocation.coordinate.latitude;
                lng = appDelegate.currentLocation.coordinate.longitude;
            }
            PFGeoPoint *eventLocation = [PFGeoPoint geoPointWithLatitude:lat longitude:lng];
            
            PFObject *eventObject = [PFObject objectWithClassName:@"Event"];
            [eventObject setObject:[PFUser currentUser] forKey:@"organizer"];
            
            //        [eventObject setObject:eventLocation forKey:@"location"];
            [eventObject setObject:self.section2Label.text forKey:@"locationName"];
            [eventObject setObject:eventLocation forKey:@"location"];
            [eventObject setObject:@"" forKey:@"additional"];
            [eventObject setObject:self.date forKey:@"time"];
            [eventObject setObject:[NSNumber numberWithBool:YES] forKey:@"isVisible"];
            
            [eventObject setObject:@"Strength Training" forKey:@"activity"];
            
            NSMutableArray *indices = [[NSMutableArray alloc] init];
            for(NSIndexPath *indexPath in self.selectedBodyParts) {
                [indices addObject:[NSNumber numberWithInteger:indexPath.row]];
            }
            [eventObject setObject:indices forKey:@"detailLogoIndices"];
            
            //        int selectedCountRow = (int) [self.countPicker selectedRowInComponent:0];
            // add 1 because it is 0 based indexing.
            [eventObject setObject:[NSNumber numberWithInt:1] forKey:@"count"];
            
            [eventObject setObject:[NSNumber numberWithInt:60] forKey:@"duration"];
            
            [eventObject setObject:[[PFUser currentUser][@"gymbudProfile"][@"name"] stringByAppendingString: [NSString stringWithFormat:@" invited you to go lift @ %@ %@. Reply IN or OUT now!", shortDate, self.section2Label, nil]] forKey:@"description"];
            
            [eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Couldn't save!");
                    NSLog(@"%@", error);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                    return;
                }
                if (succeeded) {
                    NSLog(@"Successfully saved!");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Event created!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                } else {
                    NSLog(@"Failed to save.");
                }
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        }];

    }];
    // Create event here
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Are you sure you want to create this event?"
                                                    message: @"Other GymBuds will be able to message you about it."
                                           cancelButtonItem:cancelItem
                                           otherButtonItems:goodItem, nil];
    [alert show];
    NSLog(@"button2Pressed");
}


- (IBAction)button3Pressed:(id)sender {
    // Go to find others here
    NSLog(@"button3Pressed");
    [self.navigationController.tabBarController setSelectedIndex:0];
}


- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSLog(@"name is : %@", name);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

@end
