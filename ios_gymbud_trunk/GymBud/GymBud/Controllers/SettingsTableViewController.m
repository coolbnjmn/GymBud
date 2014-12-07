//
//  SettingsTableViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 11/28/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "SettingsTableViewController.h"
#import <Parse/Parse.h>
#import "GymBudConstants.h"
#import "Mixpanel.h"
#import "SignInViewController.h"
#import "EditProfileTableViewController.h"

@interface SettingsTableViewController ()
@property (strong, nonatomic) NSMutableData* imageData;
@property (nonatomic) BOOL loadedImage;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    self.tableView.backgroundColor = kGymBudLightBlue;
    self.imageData = [[NSMutableData alloc] init];
    self.loadedImage = NO;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
     self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
}

-(void)viewDidAppear:(BOOL)animated
{
    // refresh table
    [self.tableView reloadData];
    
    if ([PFUser currentUser][@"gymbudProfile"] == nil)
    {
        [self launchEditProfile];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 100;
    else
        return 60;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    // Configure the cell...
    cell.backgroundColor = kGymBudLightBlue;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:18];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (indexPath.row)
    {
        case 0:
        {
            // edit profile
            PFUser *currentUser = [PFUser currentUser];
            NSLog(@"dictionary = %@", currentUser);
            /*if ([currentUser objectForKey:@"profile"][@"pictureURL"])
            {
                if (self.loadedImage == YES)
                {
                    cell.imageView.image = [UIImage imageWithData:self.imageData];
                }
                else
                {
                    NSURL *pictureURL = [NSURL URLWithString:[currentUser objectForKey:@"profile"][@"pictureURL"]];
                    
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                          timeoutInterval:2.0f];
                    // Run network request asynchronously
                    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    if (!urlConnection)
                    {
                        NSLog(@"Failed to download picture");
                    }
                }
            }*/

            if ([currentUser objectForKey:@"gymbudProfile"][@"profilePicture"])
            {
                PFFile *theImage = [currentUser objectForKey:@"gymbudProfile"][@"profilePicture"];
                NSLog(@"the image %@", theImage);
                __weak UITableViewCell *weakCell = cell;
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    NSLog(@"+++++++++ Loading image view with real data ++++++++");
                    if (![UIImage imageWithData:data])
                        weakCell.imageView.image = cell.imageView.image = [UIImage imageNamed:@"yogaIcon.png"];
                    else
                        weakCell.imageView.image = [UIImage imageWithData:data];
                    NSLog(@"image is %@", weakCell.imageView.image);
                }];
            }

            cell.textLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"gymbudProfile"][@"name"]];
            cell.imageView.layer.cornerRadius = 30.0f;
            cell.imageView.layer.masksToBounds = YES;
            CGSize itemSize = CGSizeMake(60, 60);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [cell.imageView.image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Invite Friend";
        }
            break;
        case 2:
        {
            // edit profile
            cell.textLabel.text = @"Enable Email Notifications";
            UISwitch *toggleNotifications = [[UISwitch alloc] init];
            [toggleNotifications setOn:NO];
            [toggleNotifications setEnabled:NO];
            [toggleNotifications addTarget:self action:@selector(pushToggled:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = toggleNotifications;
        }
            break;
        case 3:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"About -- Version Number: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"Leave Feedback";
        }
            break;
        case 5:
            cell.textLabel.text = @"Sign Out";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    switch (indexPath.row)
    {
        case 0:
            [self launchEditProfile];
            break;
        case 1:
            [self launchInviteFriend];
            break;
        case 3:
            [self launchAbout];
            break;
        case 4:
            [self launchLeaveFeedback];
            break;
        case 5:
            [self launchSignout];
            break;
            
        default:
            break;
    }
}

-(void) launchLeaveFeedback {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC LeaveFeedbackPressed" properties:@{
                                                                    }];
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"GymBud Feedback"];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"<br><br> <p> ======= Please leave your feedback above this line, the information below is to better respond to your comments ===== </p><p> objectId: %@ </p>", [[PFUser currentUser] objectId]]; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"ben@gymbudapp.com"];
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];

}

-(void) launchAbout {
    
}

-(void) launchEditProfile
{
    // show edit profile page here...
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditProfile" bundle:nil];
    EditProfileTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EPOnboarding_2"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.navigationItem.hidesBackButton = NO;
    [self.navigationController pushViewController:vc animated:YES];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC EditProfile" properties:@{
                                                           }];
}

-(void) launchInviteFriend
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC InviteAFriendPressed" properties:@{
                                                                    }];
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"%@ wants to workout with you!", [PFUser currentUser][@"gymbudProfile"][@"name"]];
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"<h1>%@ has invited you to a workout. </h1><h2> Download GymBud to join them! <a href=\"https://itunes.apple.com/us/app/gymbuducla/id935537048?ls=1&mt=8\"> Go to App Store </a></h2>", [PFUser currentUser][@"gymbudProfile"][@"name"]]; // Change the message body to HTML
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

-(void) launchSignout
{
    NSLog(@"logoutbutton being pressed");
    // Logout user, this automatically clears the cache
    [PFUser logOut];
    // Return to login view controller
    SignInViewController *lvc = [[SignInViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:nil];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SettingsVC Logout" properties:@{
                                                      }];
}

- (void)pushToggled:(id)sender
{
    
//    if ([sender isKindOfClass:[UISwitch class]])
//    {
//        UISwitch *pushNot = (UISwitch *) sender;
//        NSInteger yesOrNo = [pushNot isOn];
//        if(yesOrNo == 0)
//        {
//            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
//            {
//                // use registerUserNotificationSettings
//                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//            } else
//            {
//                // use registerForRemoteNotifications
//                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
//            }
//        }
//        else
//        {
//            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//        }
//        Mixpanel *mixpanel = [Mixpanel sharedInstance];
//        [mixpanel track:@"SettingsVC TogglePush" properties:@{
//                                                          }];
//    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.loadedImage = YES;
    [self.tableView reloadData];
}

@end
