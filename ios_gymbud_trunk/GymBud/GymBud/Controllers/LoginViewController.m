
#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import "MessageInboxTVC.h"
#import "SettingsVC.h"
#import "GoActivityCVC.h"
#import "GBJoinedEventsTVC.h"


#import <Parse/Parse.h>

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";
    
}

#pragma mark - Login mehtods
- (void)setUpTabBar {
    // Notifications stuff first:
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    PAWWallViewController *mapVC = [[PAWWallViewController alloc] init];
    MessageInboxTVC *inboxVC = [[MessageInboxTVC alloc] init];
    SettingsVC *settingsVC = [[SettingsVC alloc] init];
    UIStoryboard *goSB = [UIStoryboard storyboardWithName:@"GoActivity" bundle:nil];
    GoActivityCVC *goVC = [goSB instantiateViewControllerWithIdentifier:@"GoActivity"];
    goVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    GBJoinedEventsTVC *joinedVC = [[GBJoinedEventsTVC alloc] init];
    
    UINavigationController *nvc1 = [[UINavigationController alloc] initWithRootViewController:mapVC];
    UINavigationController *nvc2 = [[UINavigationController alloc] initWithRootViewController:inboxVC];
    UINavigationController *nvc3 = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    UINavigationController *nvc4 = [[UINavigationController alloc] initWithRootViewController:goVC];
    UINavigationController *nvc5 = [[UINavigationController alloc] initWithRootViewController:joinedVC];
    nvc1.navigationBar.tintColor= [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    nvc1.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    nvc2.navigationBar.tintColor= [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    nvc2.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    nvc3.navigationBar.tintColor= [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    nvc3.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    nvc4.navigationBar.tintColor= [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    nvc4.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    nvc5.navigationBar.tintColor= [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    nvc5.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    
    nvc1.tabBarItem.title = nil;
    nvc1.tabBarItem.image = [UIImage imageNamed:@"centeredPeople.png"];
    nvc2.tabBarItem.title = nil;
    nvc2.tabBarItem.image = [UIImage imageNamed:@"centeredInbox.png"];
    nvc3.tabBarItem.title = nil;
    nvc3.tabBarItem.image = [UIImage imageNamed:@"centeredGear.png"];
    nvc4.tabBarItem.title = @"GO";
    nvc4.tabBarItem.image = nil;
    nvc5.tabBarItem.title = @"Joined";
    nvc5.tabBarItem.image = nil;
    
    NSMutableArray *tbcArray = [[NSMutableArray alloc] initWithObjects:nvc1, nvc2, nvc4, nvc5, nvc3, nil];
    tbc.tabBar.tintColor = [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:44/255.0f green:62/255.0f blue:80/255.0f alpha:1.0f]
                                                        } forState:UIControlStateNormal];
    tbc.tabBar.barTintColor = [UIColor colorWithRed:60/255.0f green:151/255.0f blue:211/255.0f alpha:1.0f];
    tbc.viewControllers = tbcArray;

    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"user_fb_name"];
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    [self presentViewController:tbc animated:YES completion:nil];
}

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    NSLog(@"current user is: %@", [PFUser currentUser]);

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
        } else {
            NSLog(@"User with facebook logged in!");
            [self setUpTabBar];
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
