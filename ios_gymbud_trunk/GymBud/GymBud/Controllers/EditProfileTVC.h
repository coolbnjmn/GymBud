//
//  EditProfileTVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 7/15/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EPInterestVC.h"
#import "EPBasicInfoVC.h"

@interface EditProfileTVC : UITableViewController <EPInterestVCDelegate, EPBasicInfoDelegate>

@end
