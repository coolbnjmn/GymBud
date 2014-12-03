//
//  AppDelegate.h
//  GymBud
//
//  Created by Benjamin Hendricks on 7/12/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SettingsTableViewController.h"
#import "GymBudEventsTVC.h"
#import "MessageInboxTVC.h"
#import "GoActivityCVC.h"
#import "GBJoinedEventsTVC.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;
-(void) presentInitialViewController:(UITabBarController*) tabBar;
@end

