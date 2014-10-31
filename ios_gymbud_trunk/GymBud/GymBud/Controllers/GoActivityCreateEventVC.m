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
#import "Mixpanel.h"


@interface GoActivityCreateEventVC () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
//@property (weak, nonatomic) IBOutlet UIPickerView *countPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *durationPicker;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;


@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) NSMutableArray *names;
@property (nonatomic, strong) NSMutableArray *users;
@property int count;
@property MBProgressHUD *HUD;

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
//    self.locationTextField.autoCompleteTableAppearsAsKeyboardAccessory = YES;
//    self.locationTextField.autoCompleteTableBackgroundColor = [UIColor whiteColor];
    self.locationTextField.delegate = self;
    
    self.places = [[NSMutableArray alloc] init];
    
//    self.countPicker.delegate = self;
//    self.countPicker.dataSource = self;
    
    self.durationPicker.delegate = self;
    self.durationPicker.dataSource = self;
    
    PFQuery *userQuery = [PFUser query];
//    NSArray *users = [userQuery findObjectsIn];
//    self.names = [[NSMutableArray alloc] init];
//    for(PFUser *user in users) {
//        [self.names addObject:[user objectForKey:@"user_fb_name"]];
//    }
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.names = [[NSMutableArray alloc] init];
        self.users = [[NSMutableArray alloc] init];
        for(PFUser *user in objects) {
            [self.names addObject:[user objectForKey:@"user_fb_name"]];
            [self.users addObject:user];
        }
    }];
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

#pragma mark - UIPickerView Data Source & Delegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    if(pickerView == self.countPicker) {
//        return 1;
//    } else
        if(pickerView == self.durationPicker) {
        return 2;
    } else return 0;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
//    if(pickerView == self.countPicker) {
//        return [kGymBudCountArray count];
//    } else
        if(pickerView == self.durationPicker && component == 0) {
        return [kGymBudDurationHourArray count];
    } else if(pickerView == self.durationPicker && component == 1) {
        return [kGymBudDurationMinuteArray count];
    } else return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
//    if(pickerView == self.countPicker) {
//        return [kGymBudCountArray objectAtIndex:row];
//    } else
    if(pickerView == self.durationPicker && component == 0) {
        return [kGymBudDurationHourArray objectAtIndex:row];
    } else if(pickerView == self.durationPicker && component == 1) {
        return [kGymBudDurationMinuteArray objectAtIndex:row];
    } else return @"N/A";
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    // do nothing here, we just get the selected index on the way out
}


#pragma mark - Button Handlers
- (void)createEventButtonHandler:(id) sender {
    // need to parse out all the elements into a parse object
    // and return to a special page.
    
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
    self.HUD.color = [UIColor whiteColor];
    [self.HUD show:YES];
    
    // now for the location
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/"];
    NSLog(@"%@", [[self.locationTextField.text stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"]);
    NSDictionary *params = @{@"address" : [[self.locationTextField.text stringByReplacingOccurrencesOfString:@", " withString:@"+"] stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                             @"sensor" : @"true",
                             @"key" : kGoogleApiKey};
    
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
        NSString *latStr;
        NSString *lngStr;
        for(id object in responseObject[@"results"]) {
            NSLog(@"%@", object);
            if([object objectForKey:@"geometry"]) {
                latStr = object[@"geometry"][@"location"][@"lat"];
                lngStr = object[@"geometry"][@"location"][@"lng"];
            }
        }
        
        CLLocationDegrees lat = [latStr doubleValue];
        CLLocationDegrees lng = [lngStr doubleValue];
        
        if(lat == 0 || lng == 0) {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            lat = appDelegate.currentLocation.coordinate.latitude;
            lng = appDelegate.currentLocation.coordinate.longitude;
        }
        PFGeoPoint *eventLocation = [PFGeoPoint geoPointWithLatitude:lat longitude:lng];
        
        PFObject *eventObject = [PFObject objectWithClassName:@"Event"];
        [eventObject setObject:[PFUser currentUser] forKey:@"organizer"];
        
//        [eventObject setObject:eventLocation forKey:@"location"];
        [eventObject setObject:self.locationTextField.text forKey:@"locationName"];
        [eventObject setObject:eventLocation forKey:@"location"];
        [eventObject setObject:self.additionalValue forKey:@"additional"];
        [eventObject setObject:self.timePickerValue forKey:@"time"];
        [eventObject setObject:[NSNumber numberWithBool:YES] forKey:@"isVisible"];
        
        [eventObject setObject:self.activity forKey:@"activity"];
        
        NSMutableArray *indices = [[NSMutableArray alloc] init];
        for(NSIndexPath *indexPath in self.bodyPartIndices) {
            [indices addObject:[NSNumber numberWithInteger:indexPath.row]];
        }
        [eventObject setObject:indices forKey:@"detailLogoIndices"];
        
//        int selectedCountRow = (int) [self.countPicker selectedRowInComponent:0];
        // add 1 because it is 0 based indexing.
        [eventObject setObject:[NSNumber numberWithInt:1] forKey:@"count"];
        
        int selectedDurationHourRow = (int) [self.durationPicker selectedRowInComponent:0];
        int selectedDurationMinuteRow = (int) [self.durationPicker selectedRowInComponent:1];
        int numHours = (int) [[kGymBudDurationHourArray objectAtIndex:selectedDurationHourRow] integerValue];
        int numMinutes = (int) [[kGymBudDurationMinuteArray objectAtIndex:selectedDurationMinuteRow] integerValue];
        int totalMinutes = numHours * 60 + numMinutes;
        [eventObject setObject:[NSNumber numberWithInt:totalMinutes] forKey:@"duration"];
        
        if(![self.descriptionTextView.text isEqualToString:@""]) {
            [eventObject setObject:self.descriptionTextView.text forKey:@"description"];
        }
        
        [eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Couldn't save!");
                NSLog(@"%@", error);
                [self.HUD hide:NO];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully saved!");
                [self.HUD hide:YES];
                NSLog(@"%@", eventObject);
                //            dispatch_async(dispatch_get_main_queue(), ^{
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePostNotification" object:nil];
                //            });
                [self.navigationController popToRootViewControllerAnimated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 2), dispatch_get_main_queue(), ^{
                    NSLog(@"selftabbarcontroller setselectedindex 0");
                    [self.tabBarController setSelectedIndex:0];
                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                    [mixpanel track:@"GoActivityCreateEventVC CreateEvent" properties:@{
                                                                                  }];

                });
                
            } else {
                NSLog(@"Failed to save.");
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
    }];
}

#pragma mark - Auto Complete Data Source / Delegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if([textField isEqual:self.locationTextField]) {
//        if(textField.text.length < 2) {
//            return YES;
//        }
//        NSLog(@"textField text is: %@", textField.text);
//        NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/autocomplete/"];
//        
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        CLLocation *currentLocation = appDelegate.currentLocation;
//        
//        NSDictionary *params = @{@"input" : [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
//                                 @"location" : [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude],
//                                 @"sensor" : @"true",
//                                 @"key" : kGoogleApiKey};
//        
//        AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
//        [httpSessionManager GET:@"json" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//            //        NSLog(@"\n============= Entity Saved Success ===\n%@",responseObject);
//            [self.places removeAllObjects];
//            for(id description in responseObject[@"predictions"]) {
//                NSLog(@"%@", description[@"description"]);
//                [self.places addObject:description[@"description"]];
//            }
//        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            NSLog(@"\n============== ERROR ====\n%@",error.userInfo);
//        }];
//        
//        return YES;
//    } else return YES;
//    
//}
//
//
//- (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
//      possibleCompletionsForString:(NSString *)string {
//    if([textField isEqual:self.locationTextField]) {
//        return self.places;
//    } else return [NSArray new];
//}
@end
