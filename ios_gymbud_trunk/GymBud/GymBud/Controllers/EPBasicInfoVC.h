//
//  EPBasicInfoVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 9/18/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPBasicInfoVC;

@protocol EPBasicInfoDelegate <NSObject>
- (void) editProfileBasicInfoViewController:(EPBasicInfoVC *)vc didSetValues:(NSString *)name age:(NSString *)age andGender:(NSString *)gender;

@end

@interface EPBasicInfoVC : UITableViewController

@property (nonatomic, weak) id <EPBasicInfoDelegate> delegate;


- (void) setCurrentValues:(NSString *)name age:(NSString *)age andGender:(NSString *)gender;


@end
