//
//  SettingsVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/23/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "SettingsVC.h"
#import "EditProfileTVC.h"
#import "LoginViewController.h"
#import "RSDatePickerVC.h"
#import "GBJoinedEventsTVC.h"

@interface SettingsVC ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *enablePushSegmentedControl;
@end

@implementation SettingsVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editProfile:(id)sender {
    // show edit profile page here...
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditProfile" bundle:nil];
    EditProfileTVC *vc = [sb instantiateViewControllerWithIdentifier:@"EditProfile"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)logout:(id)sender {
    NSLog(@"logoutbutton being pressed");
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    LoginViewController *lvc = [[LoginViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:nil];
}

- (IBAction)enablePushOrNot:(id)sender {
    NSInteger yesOrNo = [sender selectedSegmentIndex];
    if(yesOrNo == 0) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

-(IBAction)showCalendarPressed:(id)sender {
    RSDatePickerVC *datePickerVC = [RSDatePickerVC new];
    [self.navigationController pushViewController:datePickerVC animated:YES];
}

- (IBAction)showGoPage:(id)sender {
    GBJoinedEventsTVC *vc = [[GBJoinedEventsTVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
