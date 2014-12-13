//
//  SignUpViewController.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/1/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (nonatomic) int keyboardPresent;
@end

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signUpView.logo.hidden = YES;
    self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
    self.signUpView.emailAsUsername = YES;
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
}

-(void)keyboardWillShow
{
    self.keyboardPresent = 110;
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


- (void)viewDidLayoutSubviews
{
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
            scalingFactor = 50 + self.keyboardPresent;
        }
    }

    
    // Set frame for elements
    [self.signUpView.usernameField setFrame:CGRectMake(0.0f, 285.0f-scalingFactor, 360.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(0.0f, 325.0f-scalingFactor, 360.0f, 50.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 430.0f-scalingFactor, 250.0f, 40.0f)];
}
@end
