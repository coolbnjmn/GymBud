//
//  GoActivityChosenVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GoActivityChosenVC.h"
#import <MLPAutoCompleteTextField/MLPAutoCompleteTextField.h>
#import "GoActivityCreateEventVC.h"
#import "PAWWallPostsTableViewController.h"
#import "GymBudEventsTVC.h"
#import "GymBudConstants.h"

@interface GoActivityChosenVC () <MLPAutoCompleteTextFieldDataSource, MLPAutoCompleteTextFieldDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *additionalTextField;
@property (weak, nonatomic) IBOutlet UILabel *bodyPartLabel;

@property (strong, nonatomic) NSMutableArray *additionalContent;
@end

@implementation GoActivityChosenVC

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
    NSLog(@"view did load with activity : %@" , self.activity);
    self.navigationItem.title = self.activity;
    self.bodyPartLabel.text = @"";
    for (NSIndexPath *indexPath in self.bodyPartIndices) {
        self.bodyPartLabel.text = [[self.bodyPartLabel.text stringByAppendingString:[kGBBodyPartArray objectAtIndex:indexPath.row]] stringByAppendingString:@" "];
    }
    if(!([self.activity isEqualToString:@"Sports"] || [self.activity isEqualToString:@"Other"] || [self.activity isEqualToString:@"Running"])) {
        self.additionalTextField.hidden = YES;
    } else {
        self.additionalTextField.delegate = self;
        self.additionalTextField.autoCompleteTableAppearsAsKeyboardAccessory = YES;
        self.additionalTextField.autoCompleteTableBackgroundColor = [UIColor whiteColor];
        self.additionalTextField.hidden = NO;
        self.additionalContent = [[NSMutableArray alloc] init];
        if([self.activity isEqualToString:@"Sports"]) {
            self.bodyPartLabel.text = @"Enter a sport:";
            self.bodyPartLabel.textAlignment = NSTextAlignmentLeft;
            self.additionalContent = [NSMutableArray arrayWithArray:kGBSports];
        } else if([self.activity isEqualToString:@"Other"]) {
            self.bodyPartLabel.text = @"Enter an activity:";
            self.bodyPartLabel.textAlignment = NSTextAlignmentLeft;
            self.additionalContent = [NSMutableArray arrayWithArray:kGBOther];
        } else if([self.activity isEqualToString:@"Running"]) {
            self.bodyPartLabel.text = @"Your average mile time:";
            self.bodyPartLabel.textAlignment = NSTextAlignmentLeft;
            self.additionalContent = [NSMutableArray arrayWithArray:kGBMileTimes];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findOthersPressed:(id)sender {
    GymBudEventsTVC *dvc = [[GymBudEventsTVC alloc] init];
    dvc.activityFilter = self.activity;
    dvc.timeFiler = self.startTimePicker.date;
    dvc.additionalFilter = self.additionalTextField.text;
    dvc.isShowingMap = NO;
    [self.navigationController pushViewController:dvc animated:YES];
//    UINavigationController *nvc = [self.tabBarController.viewControllers objectAtIndex:0];
//    if([nvc.viewControllers count] == 1) {
//        GymBudEventsTVC *dvc = [[GymBudEventsTVC alloc] init];
//        dvc.activityFilter = self.activity;
//        dvc.timeFiler = self.startTimePicker.date;
//        dvc.isShowingMap = NO;
//        [nvc pushViewController:dvc animated:NO];
//    }
//    [self.tabBarController setSelectedIndex:0];
//    UINavigationController *goNVC = [self.tabBarController.viewControllers objectAtIndex:2];
//    // TODO: will need to change this based on new index of GO page...
//    [goNVC popToRootViewControllerAnimated:NO];
}

- (IBAction)createEventPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GoActivity" bundle:nil];
    GoActivityCreateEventVC *vc = [sb instantiateViewControllerWithIdentifier:@"GoActivityCreateEventVC"];
    vc.activity = self.activity;
    vc.bodyPartIndices = self.bodyPartIndices;
    vc.timePickerValue = self.startTimePicker.date;
    vc.additionalValue = self.additionalTextField.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.additionalTextField]) {
        if(textField.text.length < 2) {
            return YES;
        }
       
        return YES;
    } else return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField possibleCompletionsForString:(NSString *)string completionHandler:(void (^)(NSArray *))handler {
    handler(self.additionalContent);
}
- (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField possibleCompletionsForString:(NSString *)string {
    return [NSArray arrayWithArray:self.additionalContent];
}

#pragma mark - Navigation

@end
