//
//  HPLChatData.m
//
//  Created by Alex Barinov
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "HPLChatData.h"
#import <QuartzCore/QuartzCore.h>

@interface HPLChatData ()

// Private Properties
@property (readwrite, nonatomic, strong) NSDate *date;
@property (readwrite, nonatomic) HPLChatType type;
@property (readwrite, nonatomic, strong) UIView *view;
@property (readwrite, nonatomic) UIEdgeInsets insets;
@property (readwrite, nonatomic, strong) UIView *statusView;
@end



@implementation HPLChatData

#pragma mark - Lifecycle

#pragma mark - Text chat

const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(HPLChatType)type
{
    return [[HPLChatData alloc] initWithText:text date:date type:type];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(HPLChatType)type
{
    UILabel * label = [HPLChatData labelForText:text];
    UIEdgeInsets insets = (type == ChatTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type insets:insets];
}

#pragma mark - Public

- (void)setAvatar:(UIImage *)avatarImage
{
    if ( avatarImage ) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:avatarImage];
        self.avatarView = imageView;
    } else {
        self.avatarView = nil;
    }
}

- (UIImage *)avatar {
    if ( [self.avatarView isKindOfClass:[UIImageView class]]) {
        return [(UIImageView *)self.avatarView image];
    }
    return nil;
}

- (void)setMessageStatus:(HPLChatMessageStatus)messageStatus withView:(UIView*)statusView
{
    _messageStatus = messageStatus;
    _statusView = statusView;
}

- (void)setMessageStatus:(HPLChatMessageStatus)messageStatus
{
    UIView *statusView;
    
    statusView = [[UIView alloc] initWithFrame:CGRectZero];
    statusView.backgroundColor = [UIColor clearColor];
    
    switch (messageStatus) {
        case ChatStatusSending: {
            UIActivityIndicatorView *msgSendingStatus = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            msgSendingStatus.frame = CGRectMake(1.0f, 1.0f, 18.0f, 18.0f);
            [msgSendingStatus startAnimating];
            [statusView addSubview:msgSendingStatus];
        }
            break;
            
        case ChatStatusFailed: {
            UIImageView *errorAlert = [[UIImageView alloc] initWithFrame:CGRectMake(1.0f, 1.0f, 18.0f, 18.0f)];
            errorAlert.image = [UIImage imageNamed:@"chat_message_not_delivered.png"];
            [statusView addSubview:errorAlert];
        }
            break;
            
        default:
            break;
    }
    
    [self setMessageStatus:messageStatus withView:statusView];
}

+ (UILabel*)labelForText:(NSString *)text
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

- (void) setText:(NSString*)text {
    _view = [HPLChatData labelForText:text];
    _insets = (_type == ChatTypeMine ? textInsetsMine : textInsetsSomeone);
}

- (NSString*) text {
    NSCAssert([self.view isKindOfClass:[UILabel class]], @"Invalid class.");
    UILabel *label = (UILabel *) self.view;
    return label.text;
}

#pragma mark - Image chat

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(HPLChatType)type
{
    return [[HPLChatData alloc] initWithImage:image date:date type:type];
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(HPLChatType)type
{
    CGSize size = image.size;
    if (size.width > 220)
    {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
        
    UIEdgeInsets insets = (type == ChatTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type insets:insets];       
}

#pragma mark - Custom view chat

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(HPLChatType)type insets:(UIEdgeInsets)insets
{
    return [[HPLChatData alloc] initWithView:view date:date type:type insets:insets];
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(HPLChatType)type insets:(UIEdgeInsets)insets  
{
    self = [super init];
    if (self)
    {
        self.view = view;
        self.date = date;
        self.type = type;
        self.insets = insets;
    }
    return self;
}

@end
