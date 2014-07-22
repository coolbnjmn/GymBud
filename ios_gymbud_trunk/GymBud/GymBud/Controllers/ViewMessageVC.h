//
//  ViewMessageVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 7/20/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewMessageVC : UIViewController

@property (strong, nonatomic) PFObject *activity;

@end
