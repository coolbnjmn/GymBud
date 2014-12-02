//
//  SignInViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 11/30/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "GymBudConstants.h"

@interface SignInViewController () <PFSignUpViewControllerDelegate>

@end

@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]]];
    self.logInView.dismissButton.hidden = YES;
    self.logInView.usernameField.placeholder = @"Email";
    // Do any additional setup after loading the view.
    
    // Create the sign up view controller
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [self setSignUpController:signUpViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"successfully logged in");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialView"
                                                         bundle:[NSBundle mainBundle]];
    UITabBarController *root2ViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
    for (UIViewController *v in root2ViewController.viewControllers)
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
    [root2ViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:root2ViewController animated:YES completion:nil];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 430.0f, 250.0f, 40.0f)];
    [self.logInView.usernameField setFrame:CGRectMake(0.0f, 225.0f, 360.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(0.0f, 265.0f, 360.0f, 50.0f)];
    [self.logInView.logInButton setFrame:CGRectMake(0.0f, 330.0f, self.view.frame.size.width, 50.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(0.0f, 380.0f, self.view.frame.size.width, 50.0f)];
    
}

-(BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    NSLog(@"into preseignup check");
    return YES;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    NSLog(@"User dismissed the signUpViewController");
}
@end
