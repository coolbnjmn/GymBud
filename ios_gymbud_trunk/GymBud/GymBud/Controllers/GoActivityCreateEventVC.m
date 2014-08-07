//
//  GoActivityCreateEventVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "AppDelegate.h"
#import "GoActivityCreateEventVC.h"
#import "GymBudConstants.h"
#import <MLPAutoCompleteTextField/MLPAutoCompleteTextField.h>
#import <AFNetworking/AFNetworking.h>


@interface GoActivityCreateEventVC () <MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *namesTextView;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *namesTextField;

@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) NSMutableArray *names;

@end

@implementation GoActivityCreateEventVC

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
    // Do any additional setup after loading the view.
    NSLog(@"create event and activity is: %@", self.activity);
    UIBarButtonItem *createEventButton = [[UIBarButtonItem alloc] initWithTitle:@"Create Event" style:UIBarButtonItemStyleBordered target:self action:@selector(createEventButtonHandler:)];
    self.navigationItem.rightBarButtonItem = createEventButton;
    self.locationTextField.autoCompleteTableAppearsAsKeyboardAccessory = YES;
    self.locationTextField.autoCompleteTableBackgroundColor = [UIColor whiteColor];
    self.locationTextField.delegate = self;
    
    self.namesTextField.autoCompleteTableAppearsAsKeyboardAccessory = YES;
    self.namesTextField.autoCompleteTableBackgroundColor = [UIColor whiteColor];
    self.namesTextField.delegate = self;
    
    self.places = [[NSMutableArray alloc] init];
    
    PFQuery *userQuery = [PFUser query];
    NSArray *users = [userQuery findObjects];
    self.names = [[NSMutableArray alloc] init];
    for(PFUser *user in users) {
        [self.names addObject:[user objectForKey:@"user_fb_name"]];
    }
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
#pragma mark - Button Handlers
- (IBAction)addPersonButtonHandler:(id)sender {
    if([self.namesTextView.text isEqualToString:@""]) {
        self.namesTextView.text = self.namesTextField.text;
    } else if([self.namesTextView.text rangeOfString:self.namesTextField.text].location == NSNotFound) {
        self.namesTextView.text = [[self.namesTextView.text stringByAppendingString:@", "]stringByAppendingString:self.namesTextField.text];
    }
}

- (IBAction)removeAllPeopleButtonHandler:(id)sender {
    self.namesTextView.text = @"";
}

- (void)createEventButtonHandler:(id) sender {
    // need to parse out all the elements into a parse object
    // and return to a special page.
    
    
    
    // now for the location
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/"];
    NSLog(@"%@", [[self.locationTextField.text stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]);
    NSDictionary *params = @{@"address" : [[self.locationTextField.text stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                             @"sensor" : @"true",
                             @"key" : kGoogleApiKey};
    
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
        NSLog(@"%@", responseObject[@"results"][1][@"geometry"][@"location"][@"lat"]);
        NSString *latStr = responseObject[@"results"][1][@"geometry"][@"location"][@"lat"];
        NSString *lngStr = responseObject[@"results"][1][@"geometry"][@"location"][@"lng"];
        CLLocationDegrees lat = [latStr doubleValue];
        CLLocationDegrees lng = [lngStr doubleValue];
        PFGeoPoint *eventLocation = [PFGeoPoint geoPointWithLatitude:lat longitude:lng];
        
        PFObject *eventObject = [PFObject objectWithClassName:@"Event"];
        [eventObject setObject:[PFUser currentUser] forKey:@"organizer"];
        
        [eventObject setObject:eventLocation forKey:@"location"];
        
        NSArray *userNames = [self.namesTextView.text componentsSeparatedByString:@", "];
        NSLog(@"%@", userNames);
        NSMutableArray *eventUsers = [[NSMutableArray alloc] init];
        for(NSString *userName in userNames) {
            if([userName isEqualToString:@""]) {
                continue;
            }
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"user_fb_name" equalTo:userName];
            PFObject *namedUser = [userQuery getFirstObject];
            [eventUsers addObject:namedUser];
        }
        [eventObject setObject:eventUsers forKey:@"attendees"];
        [eventObject setObject:self.timePicker.date forKey:@"time"];
        [eventObject setObject:@"YES" forKey:@"isVisible"];
        
        [eventObject setObject:self.activity forKey:@"activity"];
        
        // Use PFACL to restrict future modifications to this object.
        PFACL *readOnlyACL = [PFACL ACL];
        [readOnlyACL setPublicReadAccess:YES];
        [readOnlyACL setPublicWriteAccess:NO];
        [eventObject setACL:readOnlyACL];
        [eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Couldn't save!");
                NSLog(@"%@", error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully saved!");
                NSLog(@"%@", eventObject);
                //            dispatch_async(dispatch_get_main_queue(), ^{
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePostNotification" object:nil];
                //            });
            } else {
                NSLog(@"Failed to save.");
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
    }];
}

#pragma mark - Auto Complete Data Source / Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.locationTextField]) {
        if(textField.text.length < 2) {
            return YES;
        }
        NSLog(@"textField text is: %@", textField.text);
        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *currentLocation = appDelegate.currentLocation;
        
        NSDictionary *params = @{@"input" : [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 @"location" : [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude],
                                 @"sensor" : @"true",
                                 @"key" : kGoogleApiKey};
        
        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            //        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
            [self.places removeAllObjects];
            for(id description in responseObject[@"predictions"]) {
                NSLog(@"%@", description[@"description"]);
                [self.places addObject:description[@"description"]];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
        }];
        
        return YES;
    } else return YES;
    
}


- (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
      possibleCompletionsForString:(NSString *)string {
    if([textField isEqual:self.locationTextField]) {
        return self.places;
    } else if([textField isEqual:self.namesTextField]) {
        return self.names;
    } else return [NSArray new];
}
@end
