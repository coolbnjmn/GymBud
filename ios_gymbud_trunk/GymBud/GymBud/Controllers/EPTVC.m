//
//  EPTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 11/14/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "EPTVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GymBudConstants.h"
#import "Mixpanel.h"


@interface EPTVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *profileAge;
@property (weak, nonatomic) IBOutlet UILabel *profileGender;
@property (weak, nonatomic) IBOutlet UILabel *profilePreferred;
@property (weak, nonatomic) IBOutlet UITextView *profileGoals;
@property (weak, nonatomic) IBOutlet UITextView *profileTimes;

@property (assign, nonatomic) BOOL isKeyboardShowing;
@property (assign, nonatomic) CGRect keyboardFrame;
@property (strong, nonatomic) NSMutableData* imageData;
@property (strong, nonatomic) UIView *errorToast;

@end

#define kUnspecifiedString @"Unspecified"

@implementation EPTVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"viewDidLoad ONBOARDING HAPPENING");
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonHandler:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(updateProfileButtonHandler:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser objectForKey:@"gymbudProfile"][@"goals"]) {
        self.profileGoals.text = [currentUser objectForKey:@"gymbudProfile"][@"goals"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"times"]) {
        self.profileTimes.text = currentUser[@"gymbudProfile"][@"times"];
    }
    if ([currentUser objectForKey:@"gymbudProfile"][@"name"]) {
        self.profileName.text = [currentUser objectForKey:@"gymbudProfile"][@"name"];
    } else {
        if ([currentUser objectForKey:@"profile"][@"name"]) {
            self.profileName.text = [currentUser objectForKey:@"profile"][@"name"];
        }
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"preferred"]) {
        self.profilePreferred.text = [currentUser objectForKey:@"gymbudProfile"][@"preferred"];
    } else {
        self.profilePreferred.text = kUnspecifiedString;
    }
    if ([currentUser objectForKey:@"gymbudProfile"][@"age"]) {
        self.profileAge.text = [currentUser objectForKey:@"gymbudProfile"][@"age"];
    } else {
        if ([currentUser objectForKey:@"profile"][@"age"]) {
            self.profileAge.text = [currentUser objectForKey:@"profile"][@"age"];
        }
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"gender"]) {
        self.profileGender.text = [currentUser objectForKey:@"gymbudProfile"][@"gender"];
    } else {
        if ([currentUser objectForKey:@"profile"][@"gender"]) {
            self.profileGender.text = [currentUser objectForKey:@"profile"][@"gender"];
        }
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"profilePicture"]) {
        PFFile *theImage = [currentUser objectForKey:@"gymbudProfile"][@"profilePicture"];
        __weak EPTVC *weakSelf = self;
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            NSLog(@"+++++++++ Loading image view with real data ++++++++");
            weakSelf.profilePicture.image = [UIImage imageWithData:data];
        }];
        //        self.headerImageView.image = [UIImage imageWithData:imageData];
        self.profilePicture.layer.cornerRadius = 8.0f;
        self.profilePicture.layer.masksToBounds = YES;
    } else {
        if ([currentUser objectForKey:@"profile"][@"pictureURL"]) {
            self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            NSURL *pictureURL = [NSURL URLWithString:[currentUser objectForKey:@"profile"][@"pictureURL"]];
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }
    
    self.profileGoals.delegate = self;
    self.profileTimes.delegate = self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)keyboardDidChangeFrame:(id)sender {
    self.isKeyboardShowing = self.isKeyboardShowing ? NO : YES;
    self.keyboardFrame = [[sender userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.profilePicture.image = [UIImage imageWithData:self.imageData];
    
    // Add a nice corner radius to the image
    self.profilePicture.layer.cornerRadius = 8.0f;
    self.profilePicture.layer.masksToBounds = YES;
}

- (void)cancelButtonHandler:(id)sender {
    NSLog(@"cancel update profile");
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"EPTVC CancelUpdate" properties:@{
                                                            }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateProfileButtonHandler:(id)sender {
    NSLog(@"update profile");
    NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"EPTVC SaveUpdateAttempt" properties:@{
                                                     }];
    if(([self.profileTimes.text isEqualToString:@""] || [self.profileTimes.text isEqualToString:@"Answer here..."]) || ([self.profileGoals.text isEqualToString:@""] || [self.profileGoals.text isEqualToString:@"Answer here..."]) || [self.profileName.text isEqualToString:@""] || [self.profilePreferred.text isEqualToString:@""] || [self.profilePreferred.text isEqualToString:kUnspecifiedString] || [self.profileGender.text isEqualToString:@""] || (![self.profileGender.text.lowercaseString isEqualToString:@"male"] && ![self.profileGender.text.lowercaseString isEqualToString:@"female"])) {
        // show view here
        NSString *toastMessage = @"";
        
        if([self.profilePreferred.text isEqualToString:@""] || [self.profilePreferred.text isEqualToString:kUnspecifiedString]) {
            toastMessage = [toastMessage stringByAppendingString:@"Preference required. "];
        }
        if([self.profileName.text isEqualToString:@""]) {
            toastMessage = [toastMessage stringByAppendingString:@"Name must not be empty. "];
        }
        if([self.profileAge.text isEqualToString:@""]) {
            toastMessage = [toastMessage stringByAppendingString:@"You need an age! "];
        }
        if([self.profileGender.text isEqualToString:@""] || (![self.profileGender.text.lowercaseString isEqualToString:@"male"] && ![self.profileGender.text.lowercaseString isEqualToString:@"female"])) {
            toastMessage = [toastMessage stringByAppendingString:@"Invalid Gender. "];
        }
        if([self.profileGoals.text isEqualToString:@""] || [self.profileGoals.text isEqualToString:@"Answer here..."]) {
            toastMessage = [toastMessage stringByAppendingString:@"Goals are mandatory. "];
        }
        if ([self.profileTimes.text isEqualToString:@""] || [self.profileTimes.text isEqualToString:@"Answer here..."]) {
            toastMessage = [toastMessage stringByAppendingString:@"Times are mandatory. "];
        }
        
        
        self.errorToast = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 40)];
        self.errorToast.backgroundColor = [UIColor orangeColor];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        textLabel.text = toastMessage;
        textLabel.textAlignment = NSTextAlignmentCenter;
        NSLog(@"textLabel text is: %@", textLabel.text);
        [self.errorToast addSubview:textLabel];
        UIApplication *app = [UIApplication sharedApplication];
        [app.keyWindow addSubview:self.errorToast];
        
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             if(self.keyboardFrame.origin.y == self.view.window.bounds.size.height || self.keyboardFrame.origin.y == 0) {
                                 self.errorToast.frame = CGRectMake(0, self.view.bounds.size.height - 40 - self.tabBarController.tabBar.bounds.size.height, self.view.bounds.size.width, 40);
                             } else {
                                 self.errorToast.frame = CGRectMake(0, self.view.bounds.size.height - 40 - self.keyboardFrame.size.height, self.view.bounds.size.width, 40);
                             }
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:2.0
                                                   delay:5.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.errorToast.alpha = 0.0f;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self.errorToast removeFromSuperview];
                                                  self.errorToast = nil;
                                              }];
                         }];
        return;
    }
    userProfile[@"goals"] = self.profileGoals.text;
    userProfile[@"times"] = self.profileTimes.text;
    userProfile[@"name"] = self.profileName.text;
    userProfile[@"age"] = self.profileAge.text;
    userProfile[@"gender"] = self.profileGender.text;
    userProfile[@"preferred"] = self.profilePreferred.text;
    
    NSData *imageData = UIImageJPEGRepresentation(self.profilePicture.image, 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"profilePicture.jpg" data:imageData];
    
    userProfile[@"profilePicture"] = imageFile;
    
    [[PFUser currentUser] setObject:userProfile forKey:@"gymbudProfile"];
    [[PFUser currentUser] saveInBackground];
    
    [mixpanel track:@"EPTVC SaveUpdate" properties:@{
                                                       }];

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)editProfileBasicInfoViewController:(EPBasicInfoVC *)vc didSetValues:(NSString *)name age:(NSString *)age andGender:(NSString *)gender andPreferred:(int)index {
    NSLog(@"delegate worked: stuff is here");
    self.profileName.text = name;
    self.profileAge.text = age;
    self.profileGender.text = gender;
    self.profilePreferred.text = [kPreferredTimes objectAtIndex:index];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ImagePicker Controller Delegate
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        
        self.profilePicture.image = image;
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"EPTVC ImagePickedForProfile" properties:@{}];
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        //Right some error related code...
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editProfilePicture:(id)sender {
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType =
    //    UIImagePickerControllerSourceTypeCamera;
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    
    imagePicker.allowsEditing = NO;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"EPTVC EditProfilePicture" properties:@{}];
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
}

- (IBAction)editUserInfo:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditProfile" bundle:nil];
    EPBasicInfoVC *vc = [sb instantiateViewControllerWithIdentifier:@"EPBasicInfoVC"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"EPTVC EidtUserInfo" properties:@{}];
    [vc setCurrentValues:self.profileName.text age:self.profileAge.text andGender:self.profileGender.text andPreferred:[kPreferredTimes indexOfObject:self.profilePreferred.text] > 0 ? : 1];
    
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Answer here..."]) {
        textView.text = @"";
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Answer here...";
    }
    [textView resignFirstResponder];
}

@end
