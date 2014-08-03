//
//  RSDatePickerVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/3/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSDayFlow/RSDFDatePickerView.h>


@interface RSDatePickerVC : UIViewController

@property (nonatomic, readonly, strong) RSDFDatePickerView *datePickerView;

@end
