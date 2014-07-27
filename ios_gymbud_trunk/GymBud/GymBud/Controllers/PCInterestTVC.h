//
//  PCInterestTVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 7/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCInterestTVCDelegate <NSObject>
- (void) didSelectActivity:(NSString *)activity;

@end
@interface PCInterestTVC : UITableViewController

@property (nonatomic, weak) id <PCInterestTVCDelegate> delegate;

@end
