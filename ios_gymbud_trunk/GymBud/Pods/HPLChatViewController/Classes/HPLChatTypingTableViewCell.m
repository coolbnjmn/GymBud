//
//  HPLChatTypingTableCell.m
//  HPLChatTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "HPLChatTypingTableViewCell.h"

@interface HPLChatTypingTableViewCell ()

@property (nonatomic, retain) UIImageView *typingImageView;

@end

@implementation HPLChatTypingTableViewCell

@synthesize type = _type;
@synthesize typingImageView = _typingImageView;
@synthesize showAvatar = _showAvatar;

+ (CGFloat)height
{
    return 40.0;
}

- (void)setType:(HPLChatTypingType)value {
    if (!self.typingImageView)
    {
        self.typingImageView = [[UIImageView alloc] init];
        [self addSubview:self.typingImageView];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *chatImage = nil;
    CGFloat x = 0;
    
    if (value == HPLChatTypingTypeMe)
    {
        chatImage = [UIImage imageNamed:@"typingMine.png"];
        x = self.frame.size.width - chatImage.size.width;
    }
    else
    {
        chatImage = [UIImage imageNamed:@"typingSomeone.png"]; 
        x = 0;
    }
    
    self.typingImageView.image = chatImage;
    self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
}

@end
