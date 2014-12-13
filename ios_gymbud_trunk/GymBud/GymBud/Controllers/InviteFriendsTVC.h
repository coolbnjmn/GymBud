//
//  InviteFriendsTVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 12/12/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface InviteFriendsTVC : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSArray *bodyParts;

@end
