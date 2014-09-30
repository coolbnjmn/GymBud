//
//  GymBudDetailsVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 9/30/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GymBudDetailsVC : UITableViewController  <NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *text1Label;
@property (weak, nonatomic) IBOutlet UILabel *text2Label;
@property (weak, nonatomic) IBOutlet UILabel *text3Label;

@property (nonatomic, strong) NSArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;
@property (nonatomic, strong) NSMutableData *imageData;

@property (nonatomic, strong) PFUser *user;

@end
