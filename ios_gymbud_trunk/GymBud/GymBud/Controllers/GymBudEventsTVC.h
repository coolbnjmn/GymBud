//
//  GymBudEventsTVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface GymBudEventsTVC : PFQueryTableViewController

@property (nonatomic, strong) NSString *activityFilter;
@property (nonatomic, strong) NSDate *timeFiler;
@property (nonatomic, strong) NSString *additionalFilter;
@property (nonatomic, assign) BOOL isShowingMap;

@end
