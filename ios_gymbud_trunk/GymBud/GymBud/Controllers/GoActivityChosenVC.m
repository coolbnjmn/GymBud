//
//  GoActivityChosenVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GoActivityChosenVC.h"
#import "GoActivityCreateEventVC.h"
#import "PAWWallPostsTableViewController.h"
#import "GymBudEventsTVC.h"
#import "GymBudConstants.h"

@interface GoActivityChosenVC ()

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UILabel *bodyPartLabel;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findOthersPressed:(id)sender {
    UINavigationController *nvc = [self.tabBarController.viewControllers objectAtIndex:0];
    if([nvc.viewControllers count] == 1) {
        GymBudEventsTVC *dvc = [[GymBudEventsTVC alloc] init];
        dvc.activityFilter = self.activity;
        dvc.timeFiler = self.startTimePicker.date;
        dvc.isShowingMap = NO;
        [nvc pushViewController:dvc animated:NO];
    }
    [self.tabBarController setSelectedIndex:0];
    UINavigationController *goNVC = [self.tabBarController.viewControllers objectAtIndex:2];
    // TODO: will need to change this based on new index of GO page...
    [goNVC popToRootViewControllerAnimated:NO];
}

- (IBAction)createEventPressed:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GoActivity" bundle:nil];
    GoActivityCreateEventVC *vc = [sb instantiateViewControllerWithIdentifier:@"GoActivityCreateEventVC"];
    vc.activity = self.activity;
    vc.bodyPartIndices = self.bodyPartIndices;
    vc.timePickerValue = self.startTimePicker.date;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Navigation

@end
