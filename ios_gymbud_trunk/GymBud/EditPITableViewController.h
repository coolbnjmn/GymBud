//
//  EditPITableViewController.h
//  GymBud
//
//  Created by Hashim Shafique on 12/6/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditPITableViewControllerDelegate <NSObject>

-(void) saveUserDataWithName:(NSString*) name userGender:(NSString*) gender withAge:(NSString*) age;

@end
@interface EditPITableViewController : UITableViewController
@property(nonatomic, strong) id <EditPITableViewControllerDelegate> delegate;
@property(nonatomic) NSInteger age;
@property(nonatomic, strong) NSString *gender;
@property(nonatomic, strong) NSString *name;
@end
