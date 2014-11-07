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
#import "Mixpanel.h"
#import "GymBudConstants.h"

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
    self.navigationItem.title = @"Settings";
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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC EditProfile" properties:@{
    }];
    

    
}

- (IBAction)inviteAFriend:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC InviteAFriendPressed" properties:@{
                                                           }];
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"%@ wants to workout with you!", [PFUser currentUser][kFacebookUsername]];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"<h1>%@ has invited you to a workout. </h1><h2> Download GymBud to join them! <a href=\"https:\/\/itunes.apple.com/us/app/gymbuducla/id935537048?ls=1&mt=8\"> Go to App Store </a></h2>", [PFUser currentUser][kFacebookUsername]]; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            [mixpanel track:@"SettingsVC MailCancelled" properties:@{
                                                                   }];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [mixpanel track:@"SettingsVC MailSaved" properties:@{
                                                                   }];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [mixpanel track:@"SettingsVC MailSent" properties:@{
                                                                   }];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            [mixpanel track:@"SettingsVC MailError" properties:@{
                                                                   }];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)logout:(id)sender {
    NSLog(@"logoutbutton being pressed");
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    
    // Return to login view controller
    LoginViewController *lvc = [[LoginViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:nil];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC Logout" properties:@{
                                                           }];
}

- (IBAction)enablePushOrNot:(id)sender {
    NSInteger yesOrNo = [sender selectedSegmentIndex];
    if(yesOrNo == 0) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            // use registerUserNotificationSettings
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        } else {
            // use registerForRemoteNotifications
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
        }
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC TogglePush" properties:@{
                                                           }];
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
