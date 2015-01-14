//
//  GoActivityCreateEventVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>
#import <Parse/PFCloud.h>
#import "GymBudConstants.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Mixpanel/Mixpanel.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>

#import "InviteFriendsTVC.h"

@interface InviteFriendsTVC () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *arrContactsData;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, retain) NSMutableArray *searchData;

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, retain) NSMutableArray *searchResults;

@property (nonatomic, retain) NSMutableArray *selectedResults;
@property int selectedResultsIndex;

-(void)showAddressBook;

@end

@implementation InviteFriendsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddressBook)];
    self.navigationItem.title = @"Invite Friends";
//    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inviteFriends:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    CFErrorRef * error;
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
            CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
            
            for ( int i = 0; i < nPeople; i++ )
            {
                ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
                ABMultiValueRef multiPhones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
                CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
                CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
                
                for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                    NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                    CFRelease(phoneNumberRef);
                    if(![phoneNumber isEqualToString:@"" ]) {
                        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
                        [userDict setObject:phoneNumber forKey:@"phone"];
                        NSString *name = [[((__bridge NSString *) firstName? : @"") stringByAppendingString:@" " ] stringByAppendingString:((__bridge NSString *)lastName ? : @"")];
                        [userDict setObject:name forKey:@"name"];
                        if (_arrContactsData == nil) {
                            _arrContactsData = [[NSMutableArray alloc] init];
                        }
                        [self.arrContactsData addObject:userDict];
                        
                    }
                    
                }
                CFRelease(multiPhones);
            }
            [self.tableView reloadData];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
        CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
        
        for ( int i = 0; i < nPeople; i++ )
        {
            ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
            ABMultiValueRef multiPhones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            
            for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                CFRelease(phoneNumberRef);
                if(![phoneNumber isEqualToString:@"" ]) {
                    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
                    [userDict setObject:phoneNumber forKey:@"phone"];
                    NSString *name = [[((__bridge NSString *) firstName? : @"") stringByAppendingString:@" " ] stringByAppendingString:((__bridge NSString *)lastName ? : @"")];
                    [userDict setObject:name forKey:@"name"];
                    if (_arrContactsData == nil) {
                        _arrContactsData = [[NSMutableArray alloc] init];
                    }
                    [self.arrContactsData addObject:userDict];
                    
                }
                
            }
            CFRelease(multiPhones);
        }
        [self.tableView reloadData];
    }
    else {
        // Send an alert telling user to change privacy setting in settings app
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please let us use your contacts." message:@"So you can invite your friends! Go to settings now!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
//    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBookRef );
//    CFIndex nPeople = ABAddressBookGetPersonCount( addressBookRef );
//    
//    for ( int i = 0; i < nPeople; i++ )
//    {
//        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
//        ABMultiValueRef multiPhones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
//        CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
//        CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
//        
//        for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
//            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
//            NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
//            CFRelease(phoneNumberRef);
//            if(![phoneNumber isEqualToString:@"" ]) {
//                NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
//                [userDict setObject:phoneNumber forKey:@"phone"];
//                NSString *name = [[((__bridge NSString *) firstName? : @"") stringByAppendingString:@" " ] stringByAppendingString:((__bridge NSString *)lastName ? : @"")];
//                [userDict setObject:name forKey:@"name"];
//                if (_arrContactsData == nil) {
//                    _arrContactsData = [[NSMutableArray alloc] init];
//                }
//                [self.arrContactsData addObject:userDict];
//
//            }
//            
//        }
//        CFRelease(multiPhones);
//    }
    [self.tableView reloadData];
    [self.tableView setAllowsMultipleSelection:YES];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    /*the search bar widht must be > 1, the height must be at least 44
     (the real size of the search bar)*/
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    /*contents controller is the UITableViewController, this let you to reuse
     the same TableViewController Delegate method used for the main table.*/
    
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    //set the delegate = self. Previously declared in ViewController.h
    
    self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
    //on the top of tableView.
    self.searchBar.barTintColor = kGymBudDarkBlue;
    
    self.searchResults = [NSMutableArray array];
    self.tableView.backgroundColor = kGymBudLightBlue;

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterResults:searchString];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterResults:(NSString *)searchTerm {
    NSLog(@"filterResults being called");
    [self.searchResults removeAllObjects];
    
    NSMutableArray *actualResults = [[NSMutableArray alloc] initWithCapacity:1000];
    
    for (NSDictionary *contactDict in self.arrContactsData) {
        if([contactDict[@"name"] rangeOfString:searchTerm].location == NSNotFound) {
            
        } else {
            [actualResults addObject:contactDict];
        }
    }
    [self.searchResults addObjectsFromArray:actualResults];
}


#pragma mark - Private method implementation
- (void) inviteFriends:(id) sender {
    bool alertBool = YES;
    self.selectedResultsIndex = 0;
    NSDictionary *dict = self.selectedResults[self.selectedResultsIndex];
    
    // SEND TWILIO TEXT HERE
    [self sendSMSToNumber:[dict mutableCopy] withAlert:alertBool];
    alertBool = NO;
}

/* Send invitation SMS to a phone number using Cloud Code and Twilio! */
- (void)sendSMSToNumber:(NSMutableDictionary *)userDict withAlert:(BOOL)alertSetting {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *anError = nil;
    NBPhoneNumber *myNumber = [phoneUtil parse:userDict[@"phone"]
                                 defaultRegion:@"US" error:&anError];
    
    if (anError == nil) {
        // Should check error
        NSLog(@"isValidPhoneNumber ? [%@]", [phoneUtil isValidNumber:myNumber] ? @"YES":@"NO");
        
        // E164          : +436766077303
        NSLog(@"E164          : %@", [phoneUtil format:myNumber
                                          numberFormat:NBEPhoneNumberFormatE164
                                                 error:&anError]);
        userDict[@"phone"] = [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&anError];
        // INTERNATIONAL : +43 676 6077303
        NSLog(@"INTERNATIONAL : %@", [phoneUtil format:myNumber
                                          numberFormat:NBEPhoneNumberFormatINTERNATIONAL
                                                 error:&anError]);
        // NATIONAL      : 0676 6077303
        NSLog(@"NATIONAL      : %@", [phoneUtil format:myNumber
                                          numberFormat:NBEPhoneNumberFormatNATIONAL
                                                 error:&anError]);
        // RFC3966       : tel:+43-676-6077303
        NSLog(@"RFC3966       : %@", [phoneUtil format:myNumber
                                          numberFormat:NBEPhoneNumberFormatRFC3966
                                                 error:&anError]);
    } else {
        NSLog(@"Error : %@", [anError localizedDescription]);
    }
    
    NSLog (@"extractCountryCode [%@]", [phoneUtil extractCountryCode:@"823213123123" nationalNumber:nil]);
    
    NSString *nationalNumber = nil;
    NSNumber *countryCode = [phoneUtil extractCountryCode:@"823213123123" nationalNumber:&nationalNumber];
    
    NSLog (@"extractCountryCode [%@] [%@]", countryCode, nationalNumber);
    
    NSString *shortDate = [formatter stringFromDate:self.date];
    NSString *body = [[PFUser currentUser][@"gymbudProfile"][@"name"] stringByAppendingString: [NSString stringWithFormat:@" invited you to go lift @ %@ %@. Reply IN or OUT now!", shortDate, self.location, nil]];
    [userDict setObject:body forKey:@"body"];
        
    // now for the location
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/"];
    NSLog(@"%@", [[self.location stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]);
    NSDictionary *params = @{@"address" : [[self.location stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                             @"sensor" : @"true",
                             @"key" : kGoogleApiKey};
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
    self.HUD.color = [UIColor clearColor];
    [self.HUD show:YES];
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
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        [eventQuery whereKey:@"location" nearGeoPoint:eventLocation];
        [eventQuery whereKey:@"time" equalTo:self.date];
        [eventQuery whereKey:@"locationName" equalTo:self.location];
        [eventQuery whereKey:@"organizer" equalTo:[PFUser currentUser]];
        
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if([objects count] == 0) {
                // make new object
                PFObject *eventObject = [PFObject objectWithClassName:@"Event"];
                [eventObject setObject:[PFUser currentUser] forKey:@"organizer"];
                
                [eventObject setObject:[NSArray arrayWithObjects:userDict[@"phone"], nil] forKey:@"invitees"];
                
                PFQuery *contactQuery = [PFQuery queryWithClassName:@"Contact"];
                [contactQuery whereKey:@"phone" equalTo:userDict[@"phone"]];
                [contactQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
                [contactQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if([objects count] == 0) {
                        PFObject *contactObject = [PFObject objectWithClassName:@"Contact"];
                        [contactObject setObject:userDict[@"phone"] forKey:@"phone"];
                        [contactObject setObject:userDict[@"name"] forKey:@"name"];
                        [contactObject setObject:[PFUser currentUser] forKey:@"owner"];
                        [contactObject saveInBackground];
                    }
                }];
                //                 [eventObject setObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:userDict[@"phone"], userDict[@"name"], nil] forKeys:[NSArray arrayWithObjects:@"phone", @"name", nil]], nil] forKey:@"invitees"];

                [eventObject setObject:self.location forKey:@"locationName"];
                [eventObject setObject:eventLocation forKey:@"location"];
                [eventObject setObject:@"" forKey:@"additional"];
                [eventObject setObject:self.date forKey:@"time"];
                [eventObject setObject:[NSNumber numberWithBool:YES] forKey:@"isVisible"];
                
                [eventObject setObject:@"Strength Training" forKey:@"activity"];
                
                NSMutableArray *indices = [[NSMutableArray alloc] init];
                for(NSIndexPath *indexPath in self.bodyParts) {
                    [indices addObject:[NSNumber numberWithInteger:indexPath.row]];
                }
                [eventObject setObject:indices forKey:@"detailLogoIndices"];
                
                //        int selectedCountRow = (int) [self.countPicker selectedRowInComponent:0];
                // add 1 because it is 0 based indexing.
                [eventObject setObject:[NSNumber numberWithInt:1] forKey:@"count"];
                
                [eventObject setObject:[NSNumber numberWithInt:60] forKey:@"duration"];
                
                [eventObject setObject:[[PFUser currentUser][@"gymbudProfile"][@"name"] stringByAppendingString: [NSString stringWithFormat:@" invited you to go lift @ %@ %@. Reply IN or OUT now!", shortDate, self.location, nil]] forKey:@"description"];
                
                [eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Couldn't save!");
                        NSLog(@"%@", error);
                        [self.HUD hide:NO];
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        [alertView show];
                        return;
                    }
                    if (succeeded) {
                        NSLog(@"Successfully saved!");
                        
                        [self.HUD hide:YES];
                        
                        [PFCloud callFunctionInBackground:@"inviteWithTwilio" withParameters:userDict block:^(id object, NSError *error) {
                            NSString *message = @"";
                            if (!error) {
                                message = @"Your SMS invitation has been sent!";
                            } else {
                                message = @"Uh oh, something went wrong :(";
                                [eventObject deleteInBackground];
                            }
                            
                            UIAlertView *smsSentAlertView = [[UIAlertView alloc] initWithTitle:@"Invite Sent!"
                                                                                       message:message
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"Ok"
                                                                             otherButtonTitles:nil, nil];
                            if(alertSetting) {
                                [smsSentAlertView show];
                            }
                            
                            NSLog(@"%@", eventObject);
                            self.selectedResultsIndex++;
                            
                            if(self.selectedResultsIndex == [self.selectedResults count]) {
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                
                                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                [mixpanel track:@"InviteFriendsTVC CreateEvent" properties:@{
                                                                                             
                                                                                             }];
                                [self.tableView reloadData];
                                
                            } else {
                                NSDictionary *dict = self.selectedResults[self.selectedResultsIndex];
                                
                                // SEND TWILIO TEXT HERE
                                [self sendSMSToNumber:[dict mutableCopy] withAlert:NO];
                            }
                            
                            
                        }];
                        
                    } else {
                        NSLog(@"Failed to save.");
                    }
                }];

            }
            else {
                PFObject *event = [objects objectAtIndex:0];
                NSMutableArray *invitees = [event objectForKey:@"invitees"];
                NSMutableArray *backup = [invitees copy];
                [invitees addObject:userDict[@"phone"]];
                PFQuery *contactQuery = [PFQuery queryWithClassName:@"Contact"];
                [contactQuery whereKey:@"phone" equalTo:userDict[@"phone"]];
                [contactQuery whereKey:@"owner" equalTo:[PFUser currentUser]];
                [contactQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if([objects count] == 0) {
                        PFObject *contactObject = [PFObject objectWithClassName:@"Contact"];
                        [contactObject setObject:userDict[@"phone"] forKey:@"phone"];
                        [contactObject setObject:userDict[@"name"] forKey:@"name"];
                        [contactObject setObject:[PFUser currentUser] forKey:@"owner"];
                        [contactObject saveInBackground];
                    }
                }];
                
                [event setObject:invitees forKey:@"invitees"];
                [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Couldn't save!");
                        NSLog(@"%@", error);
                        [self.HUD hide:NO];
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                        [alertView show];
                        return;
                    }
                    if (succeeded) {
                        NSLog(@"Successfully saved!");
                        
                        [self.HUD hide:YES];
                        
                        [PFCloud callFunctionInBackground:@"inviteWithTwilio" withParameters:userDict block:^(id object, NSError *error) {
                            NSString *message = @"";
                            if (!error) {
                                message = @"Your SMS invitation has been sent!";
                            } else {
                                message = @"Uh oh, something went wrong :(";
                                [event setObject:backup forKey:@"invitees"];
//                                [event deleteInBackground];
                            }
                            
                            UIAlertView *smsSentAlertView = [[UIAlertView alloc] initWithTitle:@"Invite Sent!"
                                                                                       message:message
                                                                                      delegate:nil
                                                                             cancelButtonTitle:@"Ok"
                                                                             otherButtonTitles:nil, nil];
                            if(alertSetting) {
                                [smsSentAlertView show];
                            }
                            
                            NSLog(@"%@", event);
                            self.selectedResultsIndex++;
                            
                            if(self.selectedResultsIndex == [self.selectedResults count]) {
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                
                                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                [mixpanel track:@"InviteFriendsTVC CreateEvent" properties:@{
                                                                                             
                                                                                             }];
                                [self.tableView reloadData];

                            } else {
                                NSDictionary *dict = self.selectedResults[self.selectedResultsIndex];
                                
                                // SEND TWILIO TEXT HERE
                                [self sendSMSToNumber:[dict mutableCopy] withAlert:NO];
                            }
                        }];
                        
                    } else {
                        NSLog(@"Failed to save.");
                    }
                }];
            }
        }];
        
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
    }];

}

-(void)showAddressBook{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
        [_addressBookController setPeoplePickerDelegate:self];
        _addressBookController.displayedProperties = [NSArray arrayWithObjects:
                                                      [NSNumber numberWithInt:kABPersonPhoneProperty],
                                                      nil];
        [self presentViewController:_addressBookController animated:YES completion:nil];

    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    //4
                    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [cantAddContactAlert show];
                    return;
                }
                
                //5 Accepted, do the accept thing
                _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
                [_addressBookController setPeoplePickerDelegate:self];
                _addressBookController.displayedProperties = [NSArray arrayWithObjects:
                                                        [NSNumber numberWithInt:kABPersonPhoneProperty],
                                                        nil];
                [self presentViewController:_addressBookController animated:YES completion:nil];

                
            });
        });
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView != self.searchDisplayController.searchResultsTableView) {
        return 2;
    } else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(section == 0) {
            if (self.selectedResults) {
                return self.selectedResults.count;
            }
            else{
                return 0;
            }
        } else {
            if (_arrContactsData) {
                return _arrContactsData.count;
            }
            else{
                return 0;
            }
        }
        
    } else {
        return self.searchResults.count;
    }
   
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0 && tableView != self.searchDisplayController.searchResultsTableView) {
        return @"Selected";
    } else {
        return @"Contacts";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    NSDictionary *contactInfoDict;

    if(indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView) {
        contactInfoDict = [self.selectedResults objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if (tableView != self.searchDisplayController.searchResultsTableView) {
        contactInfoDict = [_arrContactsData objectAtIndex:indexPath.row];
    } else {
        contactInfoDict = [self.searchResults objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [contactInfoDict objectForKey:@"name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [contactInfoDict objectForKey:@"phone"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1 && tableView != self.searchDisplayController.searchResultsTableView) {
        if([self.selectedResults count] > 10) {
            // Show an alert saying max is 10
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We must limit you to 10 invites per event" message:@"Select the best 10 contacts you can!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(self.selectedResults == nil) {
            self.selectedResults = [[NSMutableArray alloc] init];
        }
        [self.selectedResults addObject:[self.arrContactsData objectAtIndex:indexPath.row]];
        [self.arrContactsData removeObject:[self.arrContactsData objectAtIndex:indexPath.row]];
        [tableView reloadData];
        
    } else if(indexPath.section == 0 && tableView != self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [self.arrContactsData addObject:[self.selectedResults objectAtIndex:indexPath.row]];
        [self.selectedResults removeObject:[self.selectedResults objectAtIndex:indexPath.row]];
        [tableView reloadData];

    } else {
        if([self.selectedResults count] > 10) {
            // Show an alert saying max is 10
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We must limit you to 10 invites per event" message:@"Select the best 10 contacts you can!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(self.selectedResults == nil) {
            self.selectedResults = [[NSMutableArray alloc] init];
        }
        [self.selectedResults addObject:[self.searchResults objectAtIndex:indexPath.row]];
        [self.arrContactsData removeObject:[self.searchResults objectAtIndex:indexPath.row]];
        [self.searchResults removeObject:[self.searchResults objectAtIndex:indexPath.row]];
        [self.searchDisplayController setActive:NO];
        [self.tableView reloadData];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

}
#pragma mark - ABPeoplePickerNavigationController Delegate method implementation
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    NSString *contactName = CFBridgingRelease(ABRecordCopyCompositeName(person));
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
    [contactInfoDict setObject:contactName forKey:@"firstName"];
//    [NSString stringWithFormat:@"Picked %@", contactName ? contactName : @"No Name"];
    // Initialize the array if it's not yet initialized.
    if (_arrContactsData == nil) {
        _arrContactsData = [[NSMutableArray alloc] init];
    }
    // Add the dictionary to the array.
    [_arrContactsData addObject:contactInfoDict];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    // Initialize a mutable dictionary and give it initial values.
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
    
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);
    
    
    // Get the e-mail addresses as a multi-value property.
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
        CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
        CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        if (CFStringCompare(currentEmailLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"homeEmail"];
        }
        
        if (CFStringCompare(currentEmailLabel, kABWorkLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentEmailValue forKey:@"workEmail"];
        }
        
        CFRelease(currentEmailLabel);
        CFRelease(currentEmailValue);
    }
    CFRelease(emailsRef);
    
    
    // Get the first street address among all addresses of the selected contact.
    ABMultiValueRef addressRef = ABRecordCopyValue(person, kABPersonAddressProperty);
    if (ABMultiValueGetCount(addressRef) > 0) {
        NSDictionary *addressDict = (__bridge NSDictionary *)ABMultiValueCopyValueAtIndex(addressRef, 0);
        
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressStreetKey] forKey:@"address"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressZIPKey] forKey:@"zipCode"];
        [contactInfoDict setObject:[addressDict objectForKey:(NSString *)kABPersonAddressCityKey] forKey:@"city"];
    }
    CFRelease(addressRef);
    
    
    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person)) {
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    // Initialize the array if it's not yet initialized.
    if (_arrContactsData == nil) {
        _arrContactsData = [[NSMutableArray alloc] init];
    }
    // Add the dictionary to the array.
    [_arrContactsData addObject:contactInfoDict];
    
    // Reload the table view data.
    [self.tableView reloadData];
    
    // Dismiss the address book view controller.
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}


-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

@end
