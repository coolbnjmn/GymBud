//
//  AppDelegate.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/12/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "AppDelegate.h"
#import "GymBudTVC.h"
#import "GBBodyPartCVC.h"
#import "EditProfileTVC.h"
#import "Mixpanel.h"
#import "EPTVC.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "GymBudEventCompletionView.h"
#import <UIAlertView+Blocks.h>
#import "SWRevealViewController.h"
#import "GymBudConstants.h"
#import "SettingsTableViewController.h"
#import "SignInViewController.h"

#define MIXPANEL_TOKEN @"079a199396a3f6b60e57782e3b79d25f"
#define kGymBudEventCompletionHeight 154

@interface AppDelegate ()



@end

@implementation AppDelegate

@synthesize currentLocation;

#pragma mark - SWRevealViewDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"DXeaM3NWJz1Lca9cjOyry5lusEhYw8nwuOyI8ene" clientKey:@"j39bl4eu3iaLj2kbEbHGDx6nGcfhWWQA2IlxGx79"];
    
    [PFFacebookUtils initializeFacebook];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Initialize the library with your
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    } else {
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    PFUser *currentUser = [PFUser currentUser];
//    [currentUser fetch];
    
    NSLog(@"current user %@", currentUser);
    
    if (![[currentUser objectForKey:@"emailVerified"] boolValue] && currentUser)
    {
        // Refresh to make sure the user did not recently verify
        if (![[currentUser objectForKey:@"emailVerified"] boolValue])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verify Email"
                                                            message:@"Please verify your email before logging in"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }

    else if (currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialView"
                                                             bundle:[NSBundle mainBundle]];
        UITabBarController *root2ViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
        [self presentInitialViewController:root2ViewController];
        self.window.rootViewController = root2ViewController;
    } else {
        UIStoryboard *signin = [UIStoryboard storyboardWithName:@"SignIn" bundle:nil];
        SignInViewController *goVC = [signin instantiateViewControllerWithIdentifier:@"SignInViewController"];

        self.window.rootViewController = goVC;
    }
    
    self.filterDistance = 10;
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(notificationPayload != nil) {
        if ([notificationPayload objectForKey:@"aps"] && [[notificationPayload objectForKey:@"aps"][@"alert"] isEqualToString:@"How was your GymBud?"]) {
            NSString *message = [notificationPayload objectForKey:@"aps"][@"alert"];
                GymBudEventCompletionView *eventCompletionView = [[GymBudEventCompletionView alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height-kGymBudEventCompletionHeight, self.window.bounds.size.width, kGymBudEventCompletionHeight)];
                eventCompletionView.event = notificationPayload[@"eventObjectId"];
                [self.window.rootViewController.view addSubview:eventCompletionView];
            
        } else if ([notificationPayload objectForKey:@"requestor"] != nil) {
            NSString *message = [notificationPayload objectForKey:@"aps"][@"alert"];
            
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Deny" action:^{
                // send a push to the requestor, saying he was denied
                // leave the event open
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:[notificationPayload objectForKey:@"requestor"]];
                PFPush *requestorPush = [[PFPush alloc] init];
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                NSString *name;
                if([[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
                    name = [[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"];
                } else {
                    name = [[[PFUser currentUser] objectForKey:@"profile"] objectForKey:@"name"];
                }
                [data setObject:[NSString stringWithFormat:@"%@ went with someone else. Create your own event?", name] forKey:@"alert"];
                [data setObject:[notificationPayload objectForKey:@"eventObj"] forKey:@"eventObj"];
                [data setObject:[NSNumber numberWithBool:YES] forKey:@"createEventPush"];
                [requestorPush setData:data];
                [requestorPush setQuery:pushQuery];
                [requestorPush sendPushInBackground];
            }];
            
            RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Accept" action:^{
                // send a push to the requestor, saying he was accepted
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:[notificationPayload objectForKey:@"requestor"]];
                PFPush *requestorPush = [[PFPush alloc] init];
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                NSString *name;
                if([[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
                    name = [[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"];
                } else {
                    name = [[[PFUser currentUser] objectForKey:@"profile"] objectForKey:@"name"];
                }
                
                [data setObject:[NSString stringWithFormat:@"%@ accepted. Let's go lift!", name] forKey:@"alert"];
                [requestorPush setData:data];
                [requestorPush setQuery:pushQuery];
                [requestorPush sendPushInBackground];
                
                PFObject *eventObj = [notificationPayload objectForKey:@"eventObj"];
                [eventObj setObject:[NSArray arrayWithObjects:[PFUser currentUser], nil] forKey:@"attendees"];
                [eventObj saveInBackground];
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: message
                                                            message: nil
                                                   cancelButtonItem:cancelItem
                                                   otherButtonItems:goodItem, nil];
            [alert show];
        } else  if ([notificationPayload objectForKey:@"createEventPush"]) {
            NSString *message = [notificationPayload objectForKey:@"aps"][@"alert"];
            
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"No Thanks" action:^{
            }];
            
            RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Yes!" action:^{
                [self.window rootViewController].tabBarController.selectedIndex = 2;
                NSLog(@"create a workout!");
            }];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: message
                                                            message: nil
                                                   cancelButtonItem:cancelItem
                                                   otherButtonItems:goodItem, nil];
            [alert show];
            
        } else {
            [PFPush handlePush:notificationPayload];
        }

//        GymBudEventCompletionView *eventCompletionView = [[GymBudEventCompletionView alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height-kGymBudEventCompletionHeight, self.window.bounds.size.width, kGymBudEventCompletionHeight)];
//        eventCompletionView.event = notificationPayload[@"eventObjectId"];
//        [self.window.rootViewController.view addSubview:eventCompletionView];
    }
    
    return YES;
}

-(void) presentInitialViewController:(UITabBarController*) tabBar;
{
    for (UIViewController *v in tabBar.viewControllers)
    {
        UIViewController *vc = v;
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *nv = (UINavigationController*)vc;
            NSLog(@"hit nav class");
            [nv.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      kGymBudLightBlue,
                                                      NSForegroundColorAttributeName,
                                                      kGymBudLightBlue,
                                                      NSForegroundColorAttributeName,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                      NSForegroundColorAttributeName,
                                                      [UIFont fontWithName:@"MagistralA-Bold" size:24.0],
                                                      NSFontAttributeName,
                                                      nil]];
            nv.navigationBar.barTintColor = [UIColor whiteColor];
        }
        else
            NSLog(@"hit non nav class");
    }
    if ([PFUser currentUser][@"gymbudProfile"] != nil)
        tabBar.selectedIndex = 2;
    else
    {
        UINavigationController *nvc4 = [[tabBar viewControllers] objectAtIndex:4];
        tabBar.selectedIndex = 4;
        UIView *editToast = [[UIView alloc] initWithFrame:CGRectMake(0, nvc4.view.bounds.size.height, nvc4.view.bounds.size.width, 40)];
        editToast.backgroundColor = [UIColor orangeColor];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, nvc4.view.bounds.size.width, 40)];
        textLabel.text = @"Edit your profile now!";
        textLabel.textAlignment = NSTextAlignmentCenter;
        [editToast addSubview:textLabel];
        UIApplication *app = [UIApplication sharedApplication];
        [app.keyWindow addSubview:editToast];
        
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             editToast.frame = CGRectMake(0, nvc4.view.bounds.size.height - 40 - tabBar.tabBar.bounds.size.height, nvc4.view.bounds.size.width, 40);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:2.0
                                                   delay:5.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  editToast.alpha = 0.0f;
                                              }
                                              completion:^(BOOL finished) {
                                                  [editToast removeFromSuperview];
                                              }];
                         }];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditProfile" bundle:nil];
        EPTVC *vc = [sb instantiateViewControllerWithIdentifier:@"EPOnboarding"];
        vc.hidesBottomBarWhenPushed = YES;
        [nvc4 pushViewController:vc animated:NO];
    }
}

// needed for ios8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"register user notification settings: %@", notificationSettings);
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    NSLog(@"registering a new device");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    if([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        // bring up modal here...
        // You need to set the identifier from the Interface
        // Builder for the following line to work
        //        CarFinderViewController *pvc = [vc.storyboard instantiateViewControllerWithIdentifier:@"CarFinderViewController"];
        //        GBEventCompletionView
        GymBudEventCompletionView *eventCompletionView = [[GymBudEventCompletionView alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height/2, self.window.bounds.size.width, self.window.bounds.size.height/2)];
        eventCompletionView.event = actionSheet.title;
        [self.window.rootViewController.view addSubview:eventCompletionView];
        
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([userInfo objectForKey:@"aps"] && [[userInfo objectForKey:@"aps"][@"alert"] isEqualToString:@"How was your GymBud?"]) {
        NSString *message = [userInfo objectForKey:@"aps"][@"alert"];
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Dismiss" action:^{
            // this is the code that will be executed when the user taps "No"
            // this is optional... if you leave the action as nil, it won't do anything
            // but here, I'm showing a block just to show that you can use one if you want to.
        }];
        
        RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Good" action:^{
            // You need to set the identifier from the Interface
            // Builder for the following line to work
            //        CarFinderViewController *pvc = [vc.storyboard instantiateViewControllerWithIdentifier:@"CarFinderViewController"];
            //        GBEventCompletionView
            GymBudEventCompletionView *eventCompletionView = [[GymBudEventCompletionView alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height-kGymBudEventCompletionHeight, self.window.bounds.size.width, kGymBudEventCompletionHeight)];
            eventCompletionView.event = userInfo[@"eventObjectId"];
            [self.window.rootViewController.view addSubview:eventCompletionView];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: message
                                                        message: nil
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:goodItem, nil];
        [alert show];
    } else if ([userInfo objectForKey:@"requestor"] != nil) {
        NSString *message = [userInfo objectForKey:@"aps"][@"alert"];
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Deny" action:^{
            // send a push to the requestor, saying he was denied
            // leave the event open
            PFQuery *pushQuery = [PFInstallation query];
            PFQuery *innerQuery = [PFUser query];
            [innerQuery whereKey:@"objectId" equalTo:[userInfo objectForKey:@"requestor"][@"objectId"]];
            
            [pushQuery whereKey:@"user" matchesQuery:innerQuery];
            PFPush *requestorPush = [[PFPush alloc] init];
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            NSString *name;
            if([[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
                name = [[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"];
            } else {
                name = [[[PFUser currentUser] objectForKey:@"profile"] objectForKey:@"name"];
            }
            [data setObject:[NSString stringWithFormat:@"%@ went with someone else. Create your own event?", name] forKey:@"alert"];
            [data setObject:[userInfo objectForKey:@"eventObj"] forKey:@"eventObj"];
            [data setObject:[NSNumber numberWithBool:YES] forKey:@"createEventPush"];
            [requestorPush setData:data];
            [requestorPush setQuery:pushQuery];
            [requestorPush sendPushInBackground];
        }];
        
        RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Accept" action:^{
            // send a push to the requestor, saying he was accepted
            PFQuery *pushQuery = [PFInstallation query];
            PFQuery *innerQuery = [PFUser query];
            [innerQuery whereKey:@"objectId" equalTo:[userInfo objectForKey:@"requestor"][@"objectId"]];
            
            [pushQuery whereKey:@"user" matchesQuery:innerQuery];
//            [pushQuery whereKey:@"user" equalTo:[userInfo objectForKey:@"requestor"]];
            PFPush *requestorPush = [[PFPush alloc] init];
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            NSString *name;
            if([[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"]) {
                name = [[[PFUser currentUser] objectForKey:@"gymbudProfile"] objectForKey:@"name"];
            } else {
                name = [[[PFUser currentUser] objectForKey:@"profile"] objectForKey:@"name"];
            }
            
            [data setObject:[NSString stringWithFormat:@"%@ accepted. Let's go lift!", name] forKey:@"alert"];
            [requestorPush setData:data];
            [requestorPush setQuery:pushQuery];
            [requestorPush sendPushInBackground];
            
            PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
            [eventQuery whereKey:@"objectId" equalTo:userInfo[@"eventObj"][@"objectId"]];
            [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                PFObject *eventObj = [objects objectAtIndex:0];
                PFQuery *userQuery = [PFUser query];
                [userQuery whereKey:@"objectId" equalTo:userInfo[@"requestor"][@"objectId"]];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error2) {
                    PFObject *userObj = [users objectAtIndex:0];
                    [eventObj setObject:[NSArray arrayWithObjects:userObj, nil] forKey:@"attendees"];
                    [eventObj saveInBackground];
                }];
            }];
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: message
                                                        message: nil
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:goodItem, nil];
        [alert show];
    } else if ([userInfo objectForKey:@"createEventPush"]) {
        NSString *message = [userInfo objectForKey:@"aps"][@"alert"];
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"No Thanks" action:^{
        }];
        
        RIButtonItem *goodItem = [RIButtonItem itemWithLabel:@"Yes!" action:^{
            [self.window rootViewController].tabBarController.selectedIndex = 2;
            [[[(UITabBarController *)[self.window rootViewController] viewControllers] objectAtIndex:2] popToRootViewControllerAnimated:YES];
            NSLog(@"create a workout!");
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: message
                                                        message: nil
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:goodItem, nil];
        [alert show];

    } else {
        [PFPush handlePush:userInfo];
    }
    
    if ([userInfo objectForKey:@"badge"]) { // TODO: for now we have no badge number, will get to this.
        NSInteger badgeNumber = [[userInfo objectForKey:@"badge"] integerValue];
        [application setApplicationIconBadgeNumber:badgeNumber];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)setCurrentLocation:(CLLocation *)aCurrentLocation {
    currentLocation = aCurrentLocation;
    
    // Notify the app of the location change:
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:currentLocation forKey:@"location"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationChangeNotification" object:nil userInfo:userInfo];
    });
}

@end
