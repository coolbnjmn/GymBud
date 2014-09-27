//
//  MessageUserVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/20/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "MessageUserVC.h"
#import "AppDelegate.h"

@interface MessageUserVC ()

@end

@implementation MessageUserVC
@synthesize textView;
@synthesize user;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelMessage:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendMessage:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    // Show the keyboard/accept input.
    [textView becomeFirstResponder];
}

- (IBAction)cancelMessage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendMessage:(id)sender {
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [textView resignFirstResponder];
    
    PFUser *currentUser = [PFUser currentUser];
    
    // Stitch together a postObject and send this async to Parse
    PFObject *activityObject = [PFObject objectWithClassName:@"Activity"];
    // Activity has the following fields:
    /*
     Activity
     
     fromUser : User
     toUser : User
     type : String
     content : String
     */
    [activityObject setObject:currentUser forKey:@"fromUser"];
    [activityObject setObject:user forKey:@"toUser"];
    [activityObject setObject:@"message" forKey:@"type"];
    [activityObject setObject:textView.text forKey:@"content"];
    [activityObject setObject:[NSNumber numberWithBool:YES] forKey:@"unread"];
    [activityObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Couldn't save!");
            NSLog(@"%@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            return;
        }
        if (succeeded) {
            NSLog(@"Successfully saved!");
            NSLog(@"%@", activityObject);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePostNotification" object:nil];
//            });
        } else {
            NSLog(@"Failed to save.");
        }
    }];
    
    PFQuery *innerQuery = [PFUser query];
    
    [innerQuery whereKey:@"username" equalTo:[user objectForKey:@"username"]];
    NSLog(@"%@", user);
    NSLog(@"about to push");
    
    NSLog(@"%@", innerQuery);
    PFQuery *query = [PFInstallation query];
    
    // only return Installations that belong to a User that
    // matches the innerQuery
    [query whereKey:@"user" matchesQuery:innerQuery];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    
    NSString *name;
    if([currentUser objectForKey:@"gymbudProfile"][@"name"]) {
        name = [currentUser objectForKey:@"gymbudProfile"][@"name"];
    } else {
        name = [currentUser objectForKey:@"profile"][@"name"];
    }
    [push setMessage:[NSString stringWithFormat:@"Message From: %@", name]];
    [push sendPushInBackground];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
