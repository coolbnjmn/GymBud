//
//  GymBudFriendDetailsTableViewController.h
//  GymBud
//
//  Created by Hashim Shafique on 1/14/15.
//  Copyright (c) 2015 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GymBudFriendDetailsTableViewController : UITableViewController

@property (nonatomic, strong) PFUser *user;

@end
