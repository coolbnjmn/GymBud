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

#define MIXPANEL_TOKEN @"079a199396a3f6b60e57782e3b79d25f"
#define kGymBudEventCompletionHeight 154

@interface AppDelegate ()



@end

@implementation AppDelegate

@synthesize currentLocation;

#pragma mark - SWRevealViewDelegate

//- (id <UIViewControllerAnimatedTransitioning>)revealController:(SWRevealViewController *)revealController animationControllerForOperation:(SWRevealControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
//{
//    if ( operation != SWRevealControllerOperationReplaceRightController )
//        return nil;
//    
//    if ( [toVC isKindOfClass:[RightViewController class]] )
//    {
//        if ( [(RightViewController*)toVC wantsCustomAnimation] )
//        {
//            id<UIViewControllerAnimatedTransitioning> animationController = [[CustomAnimationController alloc] init];
//            return animationController;
//        }
//    }
//    
//    return nil;
//}
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"DXeaM3NWJz1Lca9cjOyry5lusEhYw8nwuOyI8ene" clientKey:@"j39bl4eu3iaLj2kbEbHGDx6nGcfhWWQA2IlxGx79"];
    
//    [TestFlight takeOff:@"4b49f863-25be-417b-b74b-d63985d08b5f"];
    [PFFacebookUtils initializeFacebook];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Register for push notifications
//    [application registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeBadge |
//     UIRemoteNotificationTypeAlert |
//     UIRemoteNotificationTypeSound];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    } else {
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        UITabBarController *tbc = [[UITabBarController alloc] init];
        
        UIStoryboard *goBud = [UIStoryboard storyboardWithName:@"GymBudVC" bundle:nil];
        GymBudTVC *mapVC = [goBud instantiateViewControllerWithIdentifier:@"GymBudTVC"];
        //GymBudTVC *mapVC = [[GymBudTVC alloc] init];
        MessageInboxTVC *inboxVC = [[MessageInboxTVC alloc] init];
        SettingsVC *settingsVC = [[SettingsVC alloc] init];
        UIStoryboard *goSB = [UIStoryboard storyboardWithName:@"GoActivity" bundle:nil];
//        GoActivityCVC *goVC = [goSB instantiateViewControllerWithIdentifier:@"GoActivity"];
        GBBodyPartCVC *goVC = [goSB instantiateViewControllerWithIdentifier:@"GBBodyPartCVC"];
            
        goVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        GBJoinedEventsTVC *joinedVC = [[GBJoinedEventsTVC alloc] init];
        
        UINavigationController *nvc1 = [[UINavigationController alloc] initWithRootViewController:mapVC];
        UINavigationController *nvc2 = [[UINavigationController alloc] initWithRootViewController:inboxVC];
        UINavigationController *nvc3 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
        UINavigationController *nvc4 = [[UINavigationController alloc] initWithRootViewController:goVC];
        UINavigationController *nvc5 = [[UINavigationController alloc] initWithRootViewController:joinedVC];
//        nvc1.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        nvc1.navigationBar.tintColor = kGymBudLightBlue;
        
        [nvc1.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                    NSForegroundColorAttributeName,
                                                    [UIFont fontWithName:@"Helvetica-Bold" size:24.0],
                                                    NSFontAttributeName,
                                                    nil]];
//        nvc1.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
        nvc1.navigationBar.barTintColor = kGymBudGold;
        
        nvc2.navigationBar.tintColor = kGymBudLightBlue;
        [nvc2.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                    NSForegroundColorAttributeName,
                                                    [UIFont fontWithName:@"Helvetica-Bold" size:24.0],
                                                    NSFontAttributeName,
                                                    nil]];
//        nvc2.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
        nvc2.navigationBar.barTintColor = kGymBudGold;
        
        nvc3.navigationBar.tintColor = kGymBudLightBlue;
//        nvc3.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        [nvc3.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                    NSForegroundColorAttributeName,
                                                    [UIFont fontWithName:@"Helvetica-Bold" size:24.0],
                                                    NSFontAttributeName,
                                                    nil]];
//        nvc3.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
        nvc3.navigationBar.barTintColor = kGymBudGold;
        
        nvc4.navigationBar.tintColor = kGymBudLightBlue;
//        nvc4.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        [nvc4.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   kGymBudLightBlue,
                                                   NSForegroundColorAttributeName,
                                                   kGymBudLightBlue,
                                                   NSForegroundColorAttributeName,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                   NSForegroundColorAttributeName,
                                                   [UIFont fontWithName:@"Helvetica-Bold" size:24.0],
                                                   NSFontAttributeName,
                                                    nil]];
//        nvc4.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
        nvc4.navigationBar.barTintColor = kGymBudGold;
        
        nvc5.navigationBar.tintColor = kGymBudLightBlue;
//        nvc5.navigationBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
        [nvc5.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    kGymBudLightBlue,
                                                    NSForegroundColorAttributeName,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                    NSForegroundColorAttributeName,
                                                    [UIFont fontWithName:@"Helvetica-Bold" size:24.0],
                                                    NSFontAttributeName,
                                                    nil]];
//        nvc5.navigationBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
        nvc5.navigationBar.barTintColor = kGymBudGold;
        
        nvc1.tabBarItem.title = nil;
        nvc1.tabBarItem.image = [UIImage imageNamed:@"centeredPeople.png"];
        nvc2.tabBarItem.title = nil;
        nvc2.tabBarItem.image = [UIImage imageNamed:@"centeredInbox.png"];
        nvc3.tabBarItem.title = nil;
        nvc3.tabBarItem.image = [UIImage imageNamed:@"centeredGear.png"];
        nvc4.tabBarItem.title = nil;
        nvc4.tabBarItem.image = [UIImage imageNamed:@"go.png"];
        nvc5.tabBarItem.title = nil;
        nvc5.tabBarItem.image = [UIImage imageNamed:@"join.png"];
        
        NSMutableArray *tbcArray = [[NSMutableArray alloc] initWithObjects:nvc1, nvc2, nvc4, nvc5, nvc3, nil];

//        tbc.tabBar.tintColor = [UIColor colorWithRed:229/255.0f green:116/255.0f blue:34/255.0f alpha:1.0f];
        tbc.tabBar.tintColor = kGymBudLightBlue;
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                            NSForegroundColorAttributeName : kGymBudDarkBlue
                                                            } forState:UIControlStateNormal];
//        tbc.tabBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
        tbc.tabBar.barTintColor = kGymBudGold;
        // Add this code to change StateNormal text Color,
        [UITabBarItem.appearance setTitleTextAttributes:
         @{NSForegroundColorAttributeName : [UIColor greenColor]}
                                               forState:UIControlStateNormal];
        
        // then if StateSelected should be different, you should add this code
        [UITabBarItem.appearance setTitleTextAttributes:
         @{NSForegroundColorAttributeName : [UIColor purpleColor]}
                                               forState:UIControlStateSelected];
        tbc.viewControllers = tbcArray;
        if (currentUser[@"gymbudProfile"] != nil) {
            tbc.selectedIndex = 2;
        } else {
            tbc.selectedIndex = 4;
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditProfile" bundle:nil];
            EPTVC *vc = [sb instantiateViewControllerWithIdentifier:@"EPOnboarding"];
            vc.hidesBottomBarWhenPushed = YES;
            [nvc3 pushViewController:vc animated:NO];
        }
        self.window.rootViewController = tbc;
    } else {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        self.window.rootViewController = loginViewController;
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
