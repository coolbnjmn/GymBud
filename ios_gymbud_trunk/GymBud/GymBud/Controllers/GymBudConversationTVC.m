//
//  GymBudConversationTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 10/1/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GymBudConversationTVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GymBudConstants.h"
#import "GymBudMessageCell.h"

@interface GymBudConversationTVC () <UITextFieldDelegate>

@property (strong, nonatomic) MBProgressHUD *HUD;
@property NSString *reuseId;

@end

@implementation GymBudConversationTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reuseId = @"GymBudMessageCell";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"GymBudMessageCell" bundle:nil] forCellReuseIdentifier:self.reuseId];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.tableView.estimatedRowHeight = 80.0f;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) {
        return [self.objects count];
    } else {
        return 1;
    }
}

#pragma mark - PFQueryTableViewController
- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return [self.objects objectAtIndex:indexPath.row];
    } else {
        return [[PFObject alloc] initWithClassName:@"MessageBox"];
    }
}

- (PFQuery *)queryForTable {
    
    //    if (![PFUser currentUser]) {
    //        PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    //        [query setLimit:0];
    //        return query;
    //    }
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [toUserQuery whereKey:@"toUser" equalTo:self.toUser];
    [toUserQuery whereKey:@"fromUser" equalTo:self.fromUser];
    [toUserQuery whereKey:@"type" equalTo:@"message"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [fromUserQuery whereKey:@"fromUser" equalTo:self.toUser];
    [fromUserQuery whereKey:@"toUser" equalTo:self.fromUser];
    [fromUserQuery whereKey:@"type" equalTo:@"message"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:toUserQuery,fromUserQuery,nil]];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"fromUser"];
    [query includeKey:@"toUser"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kLoadingAnimationWidth, kLoadingAnimationHeight)];
    imageView.image = [UIImage imageNamed:kLoadingImageFirst];
    //Add more images which will be used for the animation
    imageView.animationImages = kLoadingImagesArray;
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    imageView.animationDuration = kLoadingAnimationDuration;
    [imageView startAnimating];
    imageView.contentMode = UIViewContentModeScaleToFill;
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.color = [UIColor clearColor];
    
    [self.HUD show:YES];
    [self setLoadingViewEnabled:NO];
    NSLog(@"returning query for GymBudConversationTVC");
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.HUD hide:YES];
    NSLog(@"objectsDidLoad GymBudConversationTVC");
    self.tableView.tableHeaderView = nil;
    self.tableView.scrollEnabled = YES;
    
    for(PFObject *i in self.objects) {
        [i setObject:[NSNumber numberWithBool:NO] forKey:@"unread"];
        [i saveInBackground];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.objects count] != 0) {
        PFObject *message = [self.objects objectAtIndex:indexPath.row];
        NSString *tmp = message[@"content"];
        
        CGSize constraintSize = CGSizeMake(tableView.bounds.size.width, tableView.bounds.size.height);
        CGSize labelSize = [tmp sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        
        if (indexPath.section == 0) {
            return labelSize.height + 100;
        } else {
            return 80;
        }
    } else return 0;
    
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    if(indexPath.section == 0) {
        GymBudMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseId forIndexPath:indexPath];
        
        
        if(cell == nil) {
            cell = [[GymBudMessageCell alloc] init];
        }
        
        cell.image.image = [UIImage imageNamed:@"yogaIcon.png"];
        
        if([[object objectForKey:@"fromUser"][@"profile"][@"name"] isEqualToString:[PFUser currentUser][@"profile"][@"name"]]) {
            cell.text1.text = @"You";
            cell.text2.text = [object objectForKey:@"content"];
            
            PFFile *theImage = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
            __weak GymBudMessageCell *weakCell = cell;
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                NSLog(@"+++++++++ Loading image view with real data ++++++++");
                weakCell.image.image = [UIImage imageWithData:data];
            }];
        } else {
            if([object objectForKey:@"fromUser"][@"gymbudProfile"]) {
                cell.text1.text = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"name"];
            } else {
                cell.text1.text = [object objectForKey:@"fromUser"][@"profile"][@"name"];
            }
            cell.text2.text = [object objectForKey:@"content"];
            
            PFFile *theImage = [object objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
            __weak GymBudMessageCell *weakCell = cell;
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                NSLog(@"+++++++++ Loading image view with real data ++++++++");
                weakCell.image.image = [UIImage imageWithData:data];
            }];
        }
        cell.backgroundColor = [UIColor grayColor];
        
        cell.image.layer.cornerRadius = 8.0f;
        cell.image.layer.masksToBounds = YES;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BigCell"];
        
        if(!cell) {
            cell = [[PFTableViewCell alloc] init];
        }
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(8, 8, cell.frame.size.width-16, cell.frame.size.height)];
        cell.backgroundColor = [UIColor grayColor];
        [cell addSubview:textField];
        [textField setReturnKeyType:UIReturnKeySend];
        textField.delegate = self;
        
        textField.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat height = [((NSString *)[[self.objects objectAtIndex:indexPath.row] objectForKey:@"content"]) ].height;
//    return 80.0f;
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [textField resignFirstResponder];
    
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
    [activityObject setObject:self.fromUser forKey:@"toUser"];
    [activityObject setObject:@"message" forKey:@"type"];
    [activityObject setObject:textField.text forKey:@"content"];
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
            [self loadObjects];
            [self.tableView reloadData];
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePostNotification" object:nil];
            //            });
        } else {
            NSLog(@"Failed to save.");
        }
    }];
    
    PFQuery *innerQuery = [PFUser query];
    
    [innerQuery whereKey:@"username" equalTo:[self.fromUser objectForKey:@"username"]];
    NSLog(@"%@", self.toUser);
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
    

    return NO;
}

@end
