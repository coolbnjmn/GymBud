//
//  EPBasicInfoVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 9/18/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "EPBasicInfoVC.h"
#import "GymBudConstants.h"
#import "Mixpanel.h"

@interface EPBasicInfoVC () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *preferredPickerView;

@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *age;
@property (weak, nonatomic) NSString *gender;
@property (nonatomic) int preferred;

@end

@implementation EPBasicInfoVC

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [kPreferredTimes count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [kPreferredTimes objectAtIndex:row];
}

- (void) setCurrentValues:(NSString *)name age:(NSString *)age andGender:(NSString *)gender andPreferred:(int)index {
    self.name = name;
    self.age = age;
    self.gender = gender;
    self.preferred = index;
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
    [self.preferredPickerView selectRow:self.preferred inComponent:0 animated:YES];
    
}

- (void)tellDelegate:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"EPBasicInfoVC DoneEditingBasicInfo" properties:@{}];
    [self.delegate editProfileBasicInfoViewController:self didSetValues:self.nameTextField.text age:self.ageTextField.text andGender:self.genderTextField.text andPreferred:[self.preferredPickerView selectedRowInComponent:0]];
}


@end

