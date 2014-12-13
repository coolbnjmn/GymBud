//
//  EditProfileTableViewController.h
//  GymBud
//
//  Created by Benjamin Hendricks on 12/5/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface EditProfileTableViewController : UITableViewController
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end
