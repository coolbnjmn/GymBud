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
#import <UIAlertView+Blocks.h>
#import "InviteFriendsTVC.h"
#import "LocationFinderVC.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"

#define kCellHeight 70;

@interface EventDetailsTableViewController () <UITextFieldDelegate, LocationFinderVCDelegate>
@property (nonatomic, strong) NSArray* listOfSectionNames;
@property (nonatomic) BOOL isEventEditable;
@property (nonatomic) BOOL isEditModeEnabled;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *workoutTime;
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
    self.listOfSectionNames = @[@"Organizer Information", @"Excercise Type(s)", @"Time Information", @"Location Information", @"Confirmed Attendees", @"Edit Mode"];
    
    PFUser *organizer = self.objectList[@"organizer"];
    if ([[organizer objectForKey:@"username"] isEqualToString:[[PFUser currentUser] objectForKey:@"username"]])
    {
        NSLog(@"organizer is same");
        self.isEventEditable = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(plusPressed:)];
    }
    else
    {
        NSLog(@"organizer is not same %@ %@", [organizer objectForKey:@"username"], [[PFUser currentUser] objectForKey:@"username"]);
        self.isEventEditable = NO;
    }

    self.isEditModeEnabled = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.objectList saveInBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.isEventEditable)
        return 6;
    else
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
        case 5:
            return 1;
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 0)];
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
    CGFloat height = 5;
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
            if (self.isEditModeEnabled)
            {
                for (int i=1;i<7;i++)
                {
                    UIButton *imv = (UIButton*) [cell viewWithTag:i];
                    imv.hidden = NO;
                    NSNumber *indice = [NSNumber numberWithInt:i-1];
                    if ([subLogoIndices containsObject:indice])
                        [imv setImage:[UIImage imageNamed:[kGBV3ImagesSelArray objectAtIndex:[indice integerValue]]] forState:UIControlStateNormal];
                    else
                        [imv setImage:[UIImage imageNamed:[kGBV3ImagesSelArray objectAtIndex:[indice integerValue]]] forState:UIControlStateNormal];
                    [imv addTarget:self action:@selector(toggleBodyPart:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else
            {
                if (![subLogoIndices count])
                {
                    UILabel *nobody = (UILabel*)[cell viewWithTag:500];
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
                            
                            UIButton *imv = (UIButton*) [cell viewWithTag:1];
                            [imv setImage:[UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:[index integerValue]]] forState:UIControlStateNormal];
                            
                            [cell.contentView addSubview:imv];
                        } else if(subLogoIndex == 1) {
                            UIButton *imv = (UIButton*) [cell viewWithTag:2];
                            [imv setImage:[UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:[index integerValue]]] forState:UIControlStateNormal];
                            [cell.contentView addSubview:imv];
                        } else if(subLogoIndex == 2) {
                            UIButton *imv = (UIButton*) [cell viewWithTag:3];
                            [imv setImage:[UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:[index integerValue]]] forState:UIControlStateNormal];
                            [cell.contentView addSubview:imv];
                        } else {
                            UIButton *imv = (UIButton*) [cell viewWithTag:4];
                            [imv setImage:[UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:[index integerValue]]] forState:UIControlStateNormal];
                            [cell.contentView addSubview:imv];
                        }
                        subLogoIndex++;
                    }
                    for (NSInteger i = [subLogoIndices count]; i < 7; i++)
                    {
                        UIButton *imv = (UIButton*) [cell viewWithTag:i+1];
                        imv.hidden = YES;
                    }
                }
            }
        }
        break;
        case 2:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"time" forIndexPath:indexPath];
            if (indexPath.row == 0)
            {
                self.workoutTime = (UITextField*)[cell viewWithTag:1];
                UILabel *workoutDuration = (UILabel*)[cell viewWithTag:2];
                
                NSNumber *duration= [self.objectList objectForKey:@"duration"];
                NSDate *time = [self.objectList objectForKey:@"time"];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMMM dd yyyy HH:mm"];
                NSString *theDate = [dateFormat stringFromDate:time];
                
                workoutDuration.text =[NSString stringWithFormat:@"Duration: %@", duration];
                workoutDuration.font = [UIFont fontWithName:@"MagistralATT" size:12];
                workoutDuration.textColor = [UIColor whiteColor];

                self.workoutTime.text = [NSString stringWithFormat:@"Date: %@", theDate];
                self.workoutTime.font = [UIFont fontWithName:@"MagistralATT" size:16];
                self.workoutTime.textColor = [UIColor whiteColor];
                if (!self.isEditModeEnabled)
                {
                    self.workoutTime.enabled = NO;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    self.workoutTime.enabled = YES;
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
                    self.workoutTime.delegate = self;
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
                    self.workoutTime.inputAccessoryView = keyboardDoneButtonView;
                    self.workoutTime.inputView = self.datePicker;
                    
                    self.workoutTime.frame = CGRectMake(5, 5, self.view.frame.size.width-5, 55);

                }
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
                if (self.isEditModeEnabled)
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
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
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:16];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.imageView.image = nil; //[UIImage imageNamed:@"yogaIcon.png"];
        }
            break;
        case 5:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"edit" forIndexPath:indexPath];
            UILabel *editmode = (UILabel*)[cell viewWithTag:40];
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            if (!self.isEditModeEnabled)
                editmode.text = @"EDIT";
            else
                editmode.text = @"DONE";
            cell.accessoryType= UITableViewCellAccessoryNone;
        }
            break;

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
    if (indexPath.section == 3 && indexPath.row == 0)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LocationFinderVC"
                                                             bundle:[NSBundle mainBundle]];
        LocationFinderVC *locationFinder = [storyboard instantiateViewControllerWithIdentifier:@"LocationFinderVC"];
        [locationFinder setPlaceHolderText:[self.objectList objectForKey:@"locationName"]];
        [self.navigationController pushViewController:locationFinder animated:YES];
        locationFinder.delegate = self;
        
//        if(![self.section2Label.text isEqualToString:@"Select a location"]) {
//            locationFinder.input = self.section2Label.text;

    }
    else if(indexPath.section == 4)
    {
        // join event
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Dismiss" action:^{
            // this is the code that will be executed when the user taps "No"
            // this is optional... if you leave the action as nil, it won't do anything
            // but here, I'm showing a block just to show that you can use one if you want to.
        }];
        
        RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Join" action:^{
            // join event
            
            // we need to create a join request for hitting the button.
            PFObject *requestObject = [PFObject objectWithClassName:@"Request"];
            [requestObject setObject:self.objectList forKey:@"event"];
            [requestObject setObject:[PFUser currentUser] forKey:@"requestor"];
            
            [requestObject saveInBackground];
            
            UIAlertView * alertView =[[UIAlertView alloc ] initWithTitle:@"Join request received"
                                                                 message:@"The organizer will contact you soon"
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles: nil];
            [alertView show];
            
            
            PFUser *organizer = self.objectList[@"organizer"];
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
            [data setObject:self.objectList forKey:@"eventObj"];
            [data setObject:currentUser forKey:@"requestor"];
            [data setObject:@"Increment" forKey:@"badge"];
            [push setData:data];
            [push setQuery:query];
            [push sendPushInBackground];

            
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Would you like to join this event?"
                                                        message: @"The user will be notified only if you join"
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:goodItem, nil];
        [alert show];
    }
    else if (indexPath.section == 5)
    {
        self.isEditModeEnabled = !self.isEditModeEnabled;
        [self.tableView reloadData];
    }
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

- (void)plusPressed:(id)sender {
    // Invite friends here
    //    NSLog(@"button1Pressed");
    NSDate *time = [self.objectList objectForKey:@"time"];
    NSString *location = [self.objectList objectForKey:@"locationName"];
    NSArray *subLogoIndices = [self.objectList objectForKey:@"detailLogoIndices"];

    
    InviteFriendsTVC *invite = [[InviteFriendsTVC alloc] init];
    invite.date = time;
    invite.location = location;
    invite.bodyParts = subLogoIndices;
    [self.navigationController pushViewController:invite animated:YES];
    
}

-(void)toggleBodyPart:(id)sender
{
    NSLog(@"add body parts");
    UIButton *button = (UIButton*)sender;
    NSMutableArray *subLogoIndices = [self.objectList objectForKey:@"detailLogoIndices"];
    NSInteger index = button.tag - 1;
    
    if ([subLogoIndices containsObject:[NSNumber numberWithInteger:index]])
        [subLogoIndices removeObject:[NSNumber numberWithInteger:index]];
    else
        [subLogoIndices addObject:[NSNumber numberWithInteger:index]];
    
    [self.objectList setObject:subLogoIndices forKey:@"detailLogoIndices"];
    [self.tableView reloadData];

}

- (void)doneClicked:(id)sender {
    
    // Write out the date...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    //Optionally for time zone conversions
    
    [self.objectList setObject:self.datePicker.date forKey:@"time"];
    [self.workoutTime resignFirstResponder];
    [self.tableView reloadData];
}

- (void)didSetLocation:(NSString *)locationName
{
    [self.objectList setObject:locationName forKey:@"locationName"];
    [self.tableView reloadData];
    // now for the location
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/"];
    NSLog(@"%@", [[locationName stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]);

    NSDictionary *params = @{@"address" : [[locationName stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],
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
        [self.objectList setObject:eventLocation forKey:@"location"];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            NSLog(@"Im on the main thread");
            [self.tableView reloadData];
        });
    }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
    }];
}

@end
