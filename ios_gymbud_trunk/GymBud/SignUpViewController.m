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

- (void)viewDidLoad {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
