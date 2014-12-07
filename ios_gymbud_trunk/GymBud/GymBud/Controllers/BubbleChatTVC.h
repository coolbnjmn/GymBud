//
//  BubbleChatTVC.h
//  GymBud
//
//  Created by Benjamin Hendricks on 12/3/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <Parse/Parse.h>

@interface BubbleChatTVC : JSQMessagesViewController

@property (nonatomic, strong) PFUser *fromUser;
@property (nonatomic, strong) PFUser *toUser;
@end
