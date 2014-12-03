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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 430.0f, 250.0f, 40.0f)];
}
@end
