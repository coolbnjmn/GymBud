//
//  LocationFinderVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 12/11/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MLPAutoCompleteTextField/MLPAutoCompleteTextField.h>

@protocol LocationFinderVCDelegate <NSObject>

-(void) didSetLocation:(NSString *)locationName;

@end

@interface LocationFinderVC : UIViewController

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *locationFinder;
@property (nonatomic, strong) id <LocationFinderVCDelegate> delegate;
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSString *placeHolderText;

@end
