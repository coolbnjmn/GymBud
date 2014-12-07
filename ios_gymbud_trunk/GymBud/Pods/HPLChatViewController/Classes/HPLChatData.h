//
//  HPLChatData.h
//
//  Created by Alex Barinov
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>

typedef enum _HPLChatType {
    ChatTypeMine = 0,
    ChatTypeSomeoneElse = 1
} HPLChatType;

typedef enum _HPLChatMessageStatus {
    ChatStatusSending = 0,
    ChatStatusSucceeded = 1,
    ChatStatusFailed = 2
} HPLChatMessageStatus;

@interface HPLChatData : NSObject

/**
 Read-only properties.
 */
@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic, strong) UIView *statusView;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (readonly, nonatomic) HPLChatType type;

/**
 Set a custom avatar view. If nil then the default Not-Found image is used for avatar.
 */
@property (readwrite, nonatomic, strong) UIView *avatarView;


/**
 Set a custom bubble view if you don't want to use the default bubble view style.
 If nil, default style used.
 */
@property (readwrite, nonatomic, strong) UIView *bubbleView;

/**
 We depricated the avatar property in exchange for the avatarView property.
 This method will simply set the avatarView property to a UIImageView with the provided UIImage.
 */
@property (nonatomic, readwrite, strong) UIImage *avatar DEPRECATED_ATTRIBUTE;

/**
 Getter & Setter for accessing the text of the ChatData.
 */
@property (nonatomic, readwrite, strong) NSString *text;

/**
 Getter & Setter for the ChatData's delivery status
 */
@property (readwrite, nonatomic) HPLChatMessageStatus messageStatus;

/**
 Initalizers
 */
- (id)initWithText:(NSString *)text date:(NSDate *)date type:(HPLChatType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(HPLChatType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(HPLChatType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(HPLChatType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(HPLChatType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(HPLChatType)type insets:(UIEdgeInsets)insets;
- (void)setMessageStatus:(HPLChatMessageStatus)messageStatus withView:(UIView*)statusView;

@end
