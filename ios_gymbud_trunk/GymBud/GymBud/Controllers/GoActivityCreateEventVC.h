//
//  GoActivityCreateEventVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoActivityCreateEventVC : UITableViewController

@property (nonatomic, strong) NSString *activity;
@property (nonatomic, strong) NSArray *bodyPartIndices;
@property (nonatomic, strong) NSDate *timePickerValue;
@property (nonatomic, strong) NSString *additionalValue;

@end
