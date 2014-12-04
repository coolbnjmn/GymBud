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
#import <Parse/Parse.h>
#import "AppDelegate.h"

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface SignInViewController () <PFSignUpViewControllerDelegate, UIAlertViewDelegate>

@property(nonatomic) int keyboardPresent;
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
    self.keyboardPresent = 0;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

    }

    // Do any additional setup after loading the view.
    
    // Create the sign up view controller
    SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [self setSignUpController:signUpViewController];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)keyboardWillShow
{
    self.keyboardPresent = 70;
}

-(void)keyboardWillHide
{
    self.keyboardPresent = 0;
    [self viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"successfully logged in");
    // check verified email setting
    
    if (![[user objectForKey:@"emailVerified"] boolValue])
    {
        // Refresh to make sure the user did not recently verify
        if (![[user objectForKey:@"emailVerified"] boolValue])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verify Email"
                                                            message:@"Please verify your email before logging in"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialView"
                                                         bundle:[NSBundle mainBundle]];
    
    UITabBarController *root2ViewController = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate presentInitialViewController:root2ViewController];
    
    [root2ViewController setModalPresentationStyle:UIModalPresentationFullScreen];

    [self presentViewController:root2ViewController animated:YES completion:nil];
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    int scalingFactor;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height >= 568)
        {
            //iphone 5
            scalingFactor = 0 + self.keyboardPresent;
        }
        else
        {
            //iphone 3.5 inch screen iphone 3g,4s
            scalingFactor = 60 + self.keyboardPresent;
        }
    }
    
    // Set frame for elements
    [self.logInView.usernameField setFrame:CGRectMake(0.0f, 285.0f-scalingFactor, 360.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(0.0f, 325.0f-scalingFactor, 360.0f, 50.0f)];
    [self.logInView.logInButton setFrame:CGRectMake(0.0f, 385.0f-scalingFactor, self.view.frame.size.width, 50.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(0.0f, 445.0f-scalingFactor, self.view.frame.size.width, 50.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 490.0f-scalingFactor, 250.0f, 40.0f)];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
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

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL emailAddressIsValid = YES;
    
    // uncomment this code when the following parse bug has been addressed:
    // https://github.com/ParsePlatform/ParseUI-iOS/pull/6
    
    /*
    NSString *errorMsg;
    
    NSString *email = [info objectForKey:@"email"];
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        NSLog(@"key = %@ value = %@", key, field);
    }

    NSLog(@"username is %@ %@", info, email);
    if ([email rangeOfString:@"@ucla.edu"].location  == NSNotFound)
    {
        emailAddressIsValid = NO;
        errorMsg = @"Currently GymBud is only deployed for UCLA faculty and students. Please use your UCLA email address for validation.";
    }
    // Display an alert if a field wasn't completed
    if (!emailAddressIsValid)
    {
        [[[UIAlertView alloc] initWithTitle:@"Email Error"
                                    message:errorMsg
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    */
    return emailAddressIsValid;
}

@end
