//
//  HPLChatTableViewCell.h
//
//  Created by Alex Barinov
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>
#import "HPLChatData.h"

@interface HPLChatTableViewCell : UITableViewCell

@property (nonatomic, strong) HPLChatData *data;
@property (nonatomic) BOOL showAvatar;

@end
