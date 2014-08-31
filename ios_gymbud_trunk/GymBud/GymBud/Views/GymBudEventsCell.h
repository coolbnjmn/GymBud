//
//  GymBudEventsCell.h
//  GymBud
//
//  Created by Benjamin Hendricks on 8/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GymBudEventsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *capacityTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *startDateTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *subLogoImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *subLogoImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *subLogoImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *subLogoImageView4;

@end
