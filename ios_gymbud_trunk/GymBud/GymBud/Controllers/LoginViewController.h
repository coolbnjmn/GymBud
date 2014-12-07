//
//  LoginViewController.h
//  GymBud
//
//  Created by Benjamin Hendricks on 7/12/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAWWallViewController.h"
#import "MBProgressHUD.h"

@interface LoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) MBProgressHUD *HUD;

- (IBAction)loginButtonTouchHandler:(id)sender;

- (void)setUpTabBar;

@end
