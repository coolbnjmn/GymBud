//
//  SignUpViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 12/1/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signUpView.logo.hidden = YES;
    self.view.layer.contents = (id)[UIImage imageNamed:@"background.png"].CGImage;
    self.signUpView.emailAsUsername = YES;
    
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
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
            scalingFactor = 0;
        }
        else
        {
            //iphone 3.5 inch screen iphone 3g,4s
            scalingFactor = 50;
        }
    }

    
    // Set frame for elements
    [self.signUpView.usernameField setFrame:CGRectMake(0.0f, 285.0f-scalingFactor, 360.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(0.0f, 325.0f-scalingFactor, 360.0f, 50.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 430.0f-scalingFactor, 250.0f, 40.0f)];
    [self.signUpView.dismissButton setFrame:CGRectMake(20.0f, 20.0f, 40.0f, 40.0f)];
    
    
}
@end
