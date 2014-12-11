//
//  LocationFinderVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 12/11/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MLPAutoCompleteTextField/MLPAutoCompleteTextField.h>


@interface LocationFinderVC : UIViewController

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *locationFinder;
@end
