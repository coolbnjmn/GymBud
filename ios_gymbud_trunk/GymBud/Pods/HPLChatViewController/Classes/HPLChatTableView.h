//
//  HPLChatTableView.h
//
//  Created by Alex Barinov
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

#import "HPLChatTableViewDataSource.h"
#import "HPLChatTableViewCell.h"

typedef enum _HPLChatTypingType
{
    HPLChatTypingTypeNobody = 0,
    HPLChatTypingTypeMe = 1,
    HPLChatTypingTypeSomebody = 2
} HPLChatTypingType;

@interface HPLChatTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet id<HPLChatTableViewDataSource> chatDataSource;
@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic) NSTimeInterval groupInterval;
@property (nonatomic) HPLChatTypingType typingChat;
@property (nonatomic) BOOL showAvatars;
@property (nonatomic) BOOL scrollOnActivity;

-(void)scrollToBottomAnimated:(BOOL)animated;

@end
