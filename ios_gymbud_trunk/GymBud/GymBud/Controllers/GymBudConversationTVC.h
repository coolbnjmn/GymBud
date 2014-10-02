//
//  GymBudConversationTVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 10/1/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GymBudConversationTVC : PFQueryTableViewController

@property (nonatomic, strong) PFUser *fromUser;
@property (nonatomic, strong) PFUser *toUser;

@end
