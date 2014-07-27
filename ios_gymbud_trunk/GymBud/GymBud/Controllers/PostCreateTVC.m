//
//  PostCreateTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "PostCreateTVC.h"
#import "AppDelegate.h"

@interface PostCreateTVC ()
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end

@implementation PostCreateTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPost:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post Check In" style:UIBarButtonItemStyleBordered target:self action:@selector(postPost:)];
    self.navigationItem.rightBarButtonItem = postButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) didSelectActivity:(NSString *)activity {
    NSLog(@"delegate worked");
    self.activityLabel.text = activity;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelPost:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)postPost:(id)sender {
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [self.messageTextView resignFirstResponder];
    
    // Data prep:
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
    PFUser *user = [PFUser currentUser];
    
    // Stitch together a postObject and send this async to Parse
    PFObject *postObject = [PFObject objectWithClassName:@"Posts"];
    [postObject setObject:self.messageTextView.text forKey:@"text"];
    [postObject setObject:user forKey:@"user"];
    [postObject setObject:currentPoint forKey:@"location"];
    [postObject setObject:self.activityLabel.text forKey:@"activity"];
    
    // Use PFACL to restrict future modifications to this object.
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES];
    [readOnlyACL setPublicWriteAccess:NO];
    [postObject setACL:readOnlyACL];
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Couldn't save!");
            NSLog(@"%@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            return;
        }
        if (succeeded) {
            NSLog(@"Successfully saved!");
            NSLog(@"%@", postObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePostNotification" object:nil];
            });
        } else {
            NSLog(@"Failed to save.");
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"addActivity"]) {
        NSLog(@"about to add an activity");
        PCInterestTVC *destVC = [segue destinationViewController];
        destVC.delegate = self;
    }
}


@end
