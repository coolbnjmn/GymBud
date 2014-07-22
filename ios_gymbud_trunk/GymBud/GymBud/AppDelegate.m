//
//  AppDelegate.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/12/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()



@end

@implementation AppDelegate

@synthesize currentLocation;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"DXeaM3NWJz1Lca9cjOyry5lusEhYw8nwuOyI8ene" clientKey:@"j39bl4eu3iaLj2kbEbHGDx6nGcfhWWQA2IlxGx79"];
    
    [PFFacebookUtils initializeFacebook];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        // A user was cached, so skip straight to the main view
        PAWWallViewController *wallViewController =
        [[PAWWallViewController alloc] initWithNibName:nil bundle:nil];
        
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:[[LoginViewController alloc] init]];
        self.window.rootViewController = navigation;
        [navigation pushViewController:wallViewController animated:NO];
        [self.window makeKeyAndVisible];
        [[PFInstallation currentInstallation] setObject:currentUser forKey:@"user"];
        [[PFInstallation currentInstallation] saveEventually];
        
        return YES;
    }
    else
    {
        NSLog(@"no cahced user");
        // No cached user so just present the welcome screen
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
        
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }
    
    self.filterDistance = 1000;
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    NSLog(@"registering a new device");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
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
