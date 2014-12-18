//
//  EventDetailsTableViewController.h
//  GymBud
//
//  Created by Hashim Shafique on 12/17/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EventDetailsTableViewController : UITableViewController
@property(nonatomic, strong) PFObject* objectList;
@end
