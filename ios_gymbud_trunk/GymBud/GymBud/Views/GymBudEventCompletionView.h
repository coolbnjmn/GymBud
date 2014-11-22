//
//  GymBudEventCompletionView.h
//  GymBud
//
//  Created by Benjamin Hendricks on 11/21/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AXRatingView/AXRatingView.h>


@interface GymBudEventCompletionView : UIView


@property (nonatomic, strong) AXRatingView *axRView;
@property (nonatomic, strong) NSString *event;
@end
