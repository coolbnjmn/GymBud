//
//  EPBasicInfoVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 9/18/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "EPBasicInfoVC.h"

@interface EPBasicInfoVC ()

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextField *genderTextField;

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *age;
@property (weak, nonatomic) NSString *gender;

@end

@implementation EPBasicInfoVC

- (void) setCurrentValues:(NSString *)name age:(NSString *)age andGender:(NSString *)gender {
    self.name = name;
    self.age = age;
    self.gender = gender;
    
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load epbasicinfo delegate is: %@", _delegate);
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tellDelegate:)];
    self.nameTextField.text = self.name;
    self.ageTextField.text = self.age;
    self.genderTextField.text = self.gender;
    
}

- (void)tellDelegate:(id)sender {
    [self.delegate editProfileBasicInfoViewController:self didSetValues:self.nameTextField.text age:self.ageTextField.text andGender:self.genderTextField.text];
}


@end

