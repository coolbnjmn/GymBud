//
//  GoActivityCreateEventVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFCloud.h>

#import "InviteFriendsTVC.h"

@interface InviteFriendsTVC ()

@property (nonatomic, strong) NSMutableArray *arrContactsData;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

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
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
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
    [self.tableView setAllowsMultipleSelection:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private method implementation
- (void) inviteFriends:(id) sender {
    NSArray *selectedIndices = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *path in selectedIndices) {
        NSDictionary *dict = [self.arrContactsData objectAtIndex:path.row   ];
        // SEND TWILIO TEXT HERE
        [self sendSMSToNumber:[dict mutableCopy]];
    }
}

/* Send invitation SMS to a phone number using Cloud Code and Twilio! */
- (void)sendSMSToNumber:(NSMutableDictionary *)userDict {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *shortDate = [formatter stringFromDate:self.date];
    NSString *body = [[PFUser currentUser][@"gymbudProfile"][@"name"] stringByAppendingString: [NSString stringWithFormat:@" invited you to go lift @ %@ %@. Reply IN or OUT now!", shortDate, self.location, nil]];
    [userDict setObject:body forKey:@"body"];
    [PFCloud callFunctionInBackground:@"inviteWithTwilio" withParameters:userDict block:^(id object, NSError *error) {
        NSString *message = @"";
        if (!error) {
            message = @"Your SMS invitation has been sent!";
        } else {
            message = @"Uh oh, something went wrong :(";
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Invite Sent!"
                                    message:message
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
        [self.tableView reloadData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_arrContactsData) {
        return _arrContactsData.count;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSDictionary *contactInfoDict = [_arrContactsData objectAtIndex:indexPath.row];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [contactInfoDict objectForKey:@"firstName"], [contactInfoDict objectForKey:@"lastName"]];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [contactInfoDict objectForKey:@"homeNumber"] ? : [contactInfoDict objectForKey:@"mobileNumber"]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [contactInfoDict objectForKey:@"name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [contactInfoDict objectForKey:@"phone"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *selectedIndices = [tableView indexPathsForSelectedRows];
    if([selectedIndices count] > 10) {
        // Show an alert saying max is 10
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"We must limit you to 10 invites per event" message:@"Select the best 10 contacts you can!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];

        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
