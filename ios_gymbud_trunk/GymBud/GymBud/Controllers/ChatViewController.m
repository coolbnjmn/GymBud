//
//  ChatViewController.m
//  GymBud
//
//  Created by Ajan Jayant on 2014-11-29.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "ChatViewController.h"
#import "GymBud-Swift.h"

@interface ChatViewController () <LGChatControllerDelegate>

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)launchChatController
{
    LGChatController *chatController = [LGChatController new];
    // TO BE DONE: chatController.opponentImage = [UIImage imageNamed:@"YourImageName"];
    chatController.title = @"<#YourTitle#>";
    // TO BE DONE: LGChatMessage *helloWorld = [[LGChatMessage alloc] initWithContent:@"Hello World" sentByString:[LGChatMessage SentByUserString]];
    chatController.delegate = self;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - LGChatControllerDelegate

- (void)chatController:(LGChatController *)chatController didAddNewMessage:(LGChatMessage *)message
{
    NSLog(@"Did Add Message: %@", message.content);
}

- (BOOL)shouldChatController:(LGChatController *)chatController addMessage:(LGChatMessage *)message
{
    /*
     Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
     */
    return YES;
}


@end
