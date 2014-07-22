//
//  EPInterestVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 7/15/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EPInterestVC;

@protocol EPInterestVCDelegate <NSObject>
- (void) editProfileInterestViewController:(EPInterestVC *)vc didAddInterest:(NSString *)interest forInterest:(int) interestNumber;

@end

@interface EPInterestVC : UITableViewController


@property (nonatomic, weak) id <EPInterestVCDelegate> delegate;


- (void) setCurrentInterest: (int) interestNumber;


@end
