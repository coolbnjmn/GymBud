//
//  EditPITableViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 12/6/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "EditPITableViewController.h"
#import "GymBudConstants.h"

@interface EditPITableViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property(nonatomic, strong) NSArray *genderList;
@property(nonatomic, strong) NSMutableArray *ageList;
@property(nonatomic) NSInteger age;
@property(nonatomic, strong) NSString *gender;
@property(nonatomic, strong) NSString *name;

@end

@implementation EditPITableViewController

-(NSMutableArray*) ageList
{
    if (!_ageList)
        _ageList = [[NSMutableArray alloc] init];
    return _ageList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = kGymBudLightBlue;
    self.genderList = @[@"",@"Male", @"Female"];
    
    [self.ageList addObject:@""];
    for (int j=18; j<=70; j++)
    {
        [self.ageList addObject:[NSString stringWithFormat:@"%d", j]];
    }
    
    self.age = 0;
    self.gender = @"";
    self.name = @"";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonHandler:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveData:)];
    self.navigationItem.rightBarButtonItem = saveButton;

}

- (void)cancelButtonHandler:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveData:(id)sender
{
    NSArray *cells = [self.tableView visibleCells];
    
    UITextField *tf = (UITextField*)[[cells objectAtIndex:0] viewWithTag:1];
    NSString *name = tf.text;
    UITextField *tf2 = (UITextField*)[[cells objectAtIndex:1] viewWithTag:1];
    NSString *age = tf2.text;
    UITextField *tf3 = (UITextField*)[[cells objectAtIndex:2] viewWithTag:1];
    NSString *gender = tf3.text;

    [self.delegate saveUserDataWithName:name userGender:gender withAge:age];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = kGymBudLightBlue;
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"MagistralATT" size:22];
    sectionHeader.textColor = [UIColor whiteColor];
    
    switch(section) {
        case 0:sectionHeader.text = @"Personal Information"; break;
        default:sectionHeader.text = @""; break;
    }
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"info" forIndexPath:indexPath];
    
    UIImageView *iv = (UIImageView*)[cell viewWithTag:10];
    iv.image = [UIImage imageNamed:@"greenplus.png"];
    
    // Configure the cell...
    switch (indexPath.row)
    {
        case 0:
        {
            UITextField *tf = (UITextField*)[cell viewWithTag:1];
            if ([self.name length] == 0)
            {
                tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            }
            else
            {
                tf.text = self.name;
                tf.textColor = [UIColor whiteColor];
            }
            tf.textAlignment = NSTextAlignmentCenter;
            tf.font = [UIFont fontWithName:@"MagistralATT" size:18];
            tf.delegate = self;
        }
            break;
        case 1:
        {
            UITextField *tf = (UITextField*)[cell viewWithTag:1];
            if (self.age == 0)
                tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Age" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            else
            {
                tf.text = [NSString stringWithFormat:@"%ld", (long)self.age];
                tf.textColor = [UIColor whiteColor];
            }
            tf.textAlignment = NSTextAlignmentCenter;
            tf.font = [UIFont fontWithName:@"MagistralATT" size:18];
            UIPickerView *yourpicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
            yourpicker.tag = 2;
            [yourpicker setDataSource: self];
            [yourpicker setDelegate: self];
            yourpicker.showsSelectionIndicator = YES;
            tf.inputView = yourpicker;
        }
            break;
        case 2:
        {
            UITextField *tf = (UITextField*)[cell viewWithTag:1];
            if ([self.gender length] == 0)
                tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Gender" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            else
            {
                tf.text = self.gender;
                tf.textColor = [UIColor whiteColor];
            }
            tf.textAlignment = NSTextAlignmentCenter;
            tf.font = [UIFont fontWithName:@"MagistralATT" size:18];
            UIPickerView *yourpicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
            yourpicker.tag = 3;
            [yourpicker setDataSource: self];
            [yourpicker setDelegate: self];
            yourpicker.showsSelectionIndicator = YES;
            tf.inputView = yourpicker;

        }
            break;
            
        default:
            break;
    }
    cell.backgroundColor = kGymBudLightBlue;
    return cell;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if(pickerView.tag == 2)
        return [self.ageList count];
    else
        return [self.genderList count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    if (pickerView.tag == 2)
        return self.ageList[row];
    else
        return self.genderList[row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    if (pickerView.tag == 2)
    {
        self.age = [self.ageList[row] integerValue];
    }
    else
        self.gender = self.genderList[row];
    [self.tableView reloadData];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.tableView reloadData];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.name = textField.text;
    return NO;
}

@end
