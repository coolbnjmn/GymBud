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

@interface CreateInviteTVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, LocationFinderVCDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *section1Label;
@property (weak, nonatomic) IBOutlet UILabel *section2Label;
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
    
    self.selectedBodyParts = [[NSMutableArray alloc] initWithCapacity:[kGBBodyPartArray count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight;
    if(indexPath.row == 1 && indexPath.section == 0) {
        cellHeight = 200;
    } else {
        cellHeight = 40;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, cellHeight)];
    // Configure the cell...
    
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0: // Label for body parts -- section1Label
                    self.section1Label.text = @"Select Up To 4 Body Parts";
                    [cell addSubview:self.section1Label];
                    break;
                case 1: // Collection View
                    cell = [[CreateInviteCVCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"goActivityCell"];
                    [(CreateInviteCVCCell *)cell setCollectionViewDataSourceDelegate:self index:0];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            // Location Cell
            self.section2Label.text = @"Select a location";
            [cell addSubview:self.section2Label];
            break;
        case 2:
            switch(indexPath.row) {
                case 0: // Date Cell
                {
                    self.section3TextField.text = @"Select a date & time";
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

                    [cell addSubview:self.section3TextField];
            }
                    break;
                case 1: // Invite Friends button
                    [self.button1 setTitle:@"Invite Friends (SMS)" forState:UIControlStateNormal];
                    [cell addSubview:self.button1];
                    break;
                case 2: // Create event button
                    [self.button2 setTitle:@"Create an Event (Public)" forState:UIControlStateNormal];
                    [cell addSubview:self.button2];
                    break;
                case 3:
                    [self.button3 setTitle:@"Find Others" forState:UIControlStateNormal];
                    [cell addSubview:self.button3];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0: // Label for body parts -- section1Label
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                case 1: // Collection View
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            // Location Cell
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LocationFinderVC"
                                                                 bundle:[NSBundle mainBundle]];
            LocationFinderVC *locationFinder = [storyboard instantiateViewControllerWithIdentifier:@"LocationFinderVC"];            [self.navigationController pushViewController:locationFinder animated:YES];
            locationFinder.delegate = self;
            if(![self.section2Label.text isEqualToString:@"Select a location"]) {
                locationFinder.input = self.section2Label.text;
            }
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
            break;
        case 2:
            switch(indexPath.row) {
                case 0: // Date Cell
                {
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    [self setDateClicked:self];
                }
                    break;
                case 1: // Invite Friends button
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                case 2: // Create event button
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                case 3: // Find others button
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
    cell.goActivityTextLabel.font = [UIFont fontWithName:@"MagistralATT-Bold" size:18];
    cell.goActivityTextLabel.textColor = kGymBudGold;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedBodyParts count] < 4) {
        [self.selectedBodyParts addObject:indexPath];
        GoActivityCVCell *cell = (GoActivityCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //        cell.backgroundColor = [UIColor whiteColor];
        //        cell.layer.cornerRadius = 30;
        //        cell.layer.masksToBounds = YES;
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
    self.section2Label.text = locationName;
    [self.section2Label layoutIfNeeded];
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
    // Create event here
    NSLog(@"button2Pressed");
}


- (IBAction)button3Pressed:(id)sender {
    // Go to find others here
    NSLog(@"button3Pressed");
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
