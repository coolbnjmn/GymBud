
#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import "MessageInboxTVC.h"
#import "SettingsTableViewController.h"
#import "GoActivityCVC.h"
#import "GBJoinedEventsTVC.h"
#import "GymBudTVC.h"
#import "GymBudConstants.h"
#import "GBBodyPartCVC.h"
#import "EPTVC.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

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
    
    UIStoryboard *goBud = [UIStoryboard storyboardWithName:@"GymBudVC" bundle:nil];
    GymBudTVC *mapVC = [goBud instantiateViewControllerWithIdentifier:@"GymBudTVC"];
    //GymBudTVC *mapVC = [[GymBudTVC alloc] init];
    MessageInboxTVC *inboxVC = [[MessageInboxTVC alloc] init];
    SettingsTableViewController *settingsVC = [[SettingsTableViewController alloc] init];
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
    nvc1.navigationBar.barTintColor = [UIColor whiteColor];
    
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
    nvc2.navigationBar.barTintColor = [UIColor whiteColor];
    
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
    nvc3.navigationBar.barTintColor = [UIColor whiteColor];
    
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
    nvc4.navigationBar.barTintColor = [UIColor whiteColor];
    
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
    nvc5.navigationBar.barTintColor = [UIColor whiteColor];
    
    nvc1.tabBarItem.title = nil;
    nvc1.tabBarItem.image = [[UIImage imageNamed:@"centeredPeople.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc1.tabBarItem.selectedImage = [UIImage imageNamed:@"centeredPeople.png"];
    nvc2.tabBarItem.title = nil;
    nvc2.tabBarItem.image = [[UIImage imageNamed:@"centeredInbox.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc2.tabBarItem.selectedImage = [UIImage imageNamed:@"centeredInbox.png"];
    
    nvc3.tabBarItem.title = nil;
    nvc3.tabBarItem.image = [[UIImage imageNamed:@"centeredGear.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc3.tabBarItem.selectedImage = [UIImage imageNamed:@"centeredGear.png"];
    
    
    nvc4.tabBarItem.title = nil;
    nvc4.tabBarItem.image = [[UIImage imageNamed:@"go.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc4.tabBarItem.selectedImage = [UIImage imageNamed:@"go.png"];
    
    nvc5.tabBarItem.title = nil;
    nvc5.tabBarItem.image = [[UIImage imageNamed:@"join.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc5.tabBarItem.selectedImage = [UIImage imageNamed:@"join.png"];
    
    NSMutableArray *tbcArray = [[NSMutableArray alloc] initWithObjects:nvc1, nvc2, nvc4, nvc5, nvc3, nil];
    
    //        tbc.tabBar.tintColor = [UIColor colorWithRed:229/255.0f green:116/255.0f blue:34/255.0f alpha:1.0f];
    tbc.tabBar.tintColor = kGymBudLightBlue;
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f],
                                                        NSForegroundColorAttributeName : kGymBudDarkBlue
                                                        } forState:UIControlStateNormal];
    //        tbc.tabBar.barTintColor = [UIColor colorWithRed:34/255.0f green:49/255.0f blue:66/255.0f alpha:1.0f];
    tbc.tabBar.barTintColor = [UIColor whiteColor];
    tbc.viewControllers = tbcArray;
    
    if ([PFUser currentUser][@"gymbudProfile"] != nil) {
        tbc.selectedIndex = 2;
    } else {
        tbc.selectedIndex = 4;
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
                             editToast.frame = CGRectMake(0, nvc4.view.bounds.size.height - 40 - tbc.tabBar.bounds.size.height, nvc4.view.bounds.size.width, 40);
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
        [nvc3 pushViewController:vc animated:NO];
    }
    
    

    
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
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                NSDate *birthday = [dateFormatter dateFromString:userData[@"birthday"]];
                NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                                   components:NSYearCalendarUnit
                                                   fromDate:birthday
                                                   toDate:[NSDate date]
                                                   options:0];
                NSInteger age = [ageComponents year];
                userProfile[@"age"] = [[NSNumber numberWithInt:age] stringValue];
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
//        [_activityIndicator stopAnimating]; // Hide loading indicator
        [self.HUD hide:YES];
        
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
    
//    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kLoadingAnimationWidth, kLoadingAnimationHeight)];
    imageView.image = [UIImage imageNamed:kLoadingImageFirst];
    //Add more images which will be used for the animation
    imageView.animationImages = kLoadingImagesArray;
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    imageView.animationDuration = kLoadingAnimationDuration;
    [imageView startAnimating];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.color = [UIColor whiteColor];
    [self.HUD show:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"LoginToMain"]) {
        [self setUpTabBar];
    }
}

@end
