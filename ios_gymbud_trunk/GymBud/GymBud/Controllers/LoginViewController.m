
#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import "MessageInboxTVC.h"
#import "SettingsVC.h"


#import <Parse/Parse.h>

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    
//    NSLog(@"current user is: %@", [PFUser currentUser]);
//    // Check if user is cached and linked to Facebook, if so, bypass login
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
////        [self.navigationController pushViewController:[[PAWWallViewController alloc] init] animated:NO];
////        [self performSegueWithIdentifier:@"LoginToMain" sender:self];
//        NSLog(@"setting up tab bar");
//        [self setUpTabBar];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //        [self.navigationController pushViewController:[[PAWWallViewController alloc] init] animated:NO];
        //        [self performSegueWithIdentifier:@"LoginToMain" sender:self];
        NSLog(@"setting up tab bar");
        [self setUpTabBar];
    }
}

#pragma mark - Login mehtods
- (void)setUpTabBar {
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    PAWWallViewController *mapVC = [[PAWWallViewController alloc] init];
    MessageInboxTVC *inboxVC = [[MessageInboxTVC alloc] init];
    SettingsVC *settingsVC = [[SettingsVC alloc] init];
    UINavigationController *nvc1 = [[UINavigationController alloc] initWithRootViewController:mapVC];
    UINavigationController *nvc2 = [[UINavigationController alloc] initWithRootViewController:inboxVC];
    UINavigationController *nvc3 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    
    nvc1.tabBarItem.title = @"Map";
    nvc2.tabBarItem.title = @"Inbox";
    nvc3.tabBarItem.title = @"Settings";

    NSMutableArray *tbcArray = [[NSMutableArray alloc] initWithObjects:nvc1, nvc2, nvc3, nil];
    
    tbc.viewControllers = tbcArray;
    [self presentViewController:tbc animated:YES completion:nil];
}

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self setUpTabBar];
//            [self.navigationController pushViewController:[[PAWWallViewController alloc] init] animated:YES];
        } else {
            NSLog(@"User with facebook logged in!");
            [self setUpTabBar];
//            [self.navigationController pushViewController:[[PAWWallViewController alloc] init] animated:YES];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"LoginToMain"]) {
        [self setUpTabBar];
    }
}

@end
