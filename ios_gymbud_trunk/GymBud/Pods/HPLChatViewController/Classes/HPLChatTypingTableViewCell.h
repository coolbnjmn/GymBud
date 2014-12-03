//
//  HPLChatTypingTableCell.h
//  HPLChatTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPLChatTableView.h"


@interface HPLChatTypingTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic) HPLChatTypingType type;
@property (nonatomic) BOOL showAvatar;

@end
