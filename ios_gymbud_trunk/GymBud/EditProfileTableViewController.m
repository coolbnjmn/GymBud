//
//  EditProfileTableViewController.m
//  GymBud
//
//  Created by Hashim Shafique on 12/5/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "GymBudConstants.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "EditPITableViewController.h"

@interface EditProfileTableViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditPITableViewControllerDelegate>
- (IBAction)onEditPicture:(id)sender;
@property (strong, nonatomic) NSMutableData* imageData;
@property (nonatomic) BOOL loadedImage;
@property (strong, nonatomic) UIView *errorToast;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) UIImage *profileImage;
@property (nonatomic) BOOL didUpdateUsingFacebook;
@property (nonatomic) BOOL pickedPicture;
@end

@implementation EditProfileTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadedImage = NO;

    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.backgroundColor = kGymBudLightBlue;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonHandler:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(updateProfileButtonHandler:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.profileImage = [UIImage imageNamed:@"yogaIcon.png"];
    self.didUpdateUsingFacebook = NO;
    self.pickedPicture = NO;
    
    PFUser *currentUser = [PFUser currentUser];
    
    if ([currentUser objectForKey:@"profile"][@"name"])
        self.name = [currentUser objectForKey:@"profile"][@"name"];
    else if ([currentUser objectForKey:@"gymbudProfile"][@"name"])
        self.name = [currentUser objectForKey:@"gymbudProfile"][@"name"];
    else
        self.name = @"Incomplete Profile";

    self.age = @"";
    self.gender = @"";
    
    if ([currentUser objectForKey:@"profile"][@"age"])
        self.age = [currentUser objectForKey:@"profile"][@"age"];
    else if ([currentUser objectForKey:@"gymbudProfile"][@"age"])
        self.age = [currentUser objectForKey:@"gymbudProfile"][@"age"];
    
    if ([currentUser objectForKey:@"profile"][@"gender"])
        self.gender = [currentUser objectForKey:@"profile"][@"gender"];
    else if ([currentUser objectForKey:@"gymbudProfile"][@"gender"])
        self.gender = [currentUser objectForKey:@"gymbudProfile"][@"gender"];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return 110;
    else if (indexPath.section == 1)
        return 80;
    else
        return 60;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
        return 1.0f;
    else
        return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = kGymBudLightBlue;
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont fontWithName:@"MagistralATT" size:18];
    sectionHeader.textColor = [UIColor whiteColor];
    
    switch(section) {
        case 1:sectionHeader.text = @"Personal Preferences"; break;
        default:sectionHeader.text = @""; break;
    }
    return sectionHeader;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0 && indexPath.row == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"headerrow" forIndexPath:indexPath];
    else if (indexPath.section == 1)
        cell = [tableView dequeueReusableCellWithIdentifier:@"inputtext" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"commonrow" forIndexPath:indexPath];
    // Configure the cell...

    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                // update image row
                UIImageView *img = (UIImageView*)[cell viewWithTag:1];
                img.image = [UIImage imageNamed:@"yogaIcon.png"];
                img.layer.cornerRadius = 36.0f;
                img.layer.masksToBounds = YES;
                PFUser *currentUser = [PFUser currentUser];
                NSLog(@"current user is %@", [PFUser currentUser]);

                if (self.loadedImage == YES)
                {
                    img.image = [UIImage imageWithData:self.imageData];
                    self.profileImage = [UIImage imageWithData:self.imageData];
                }
                else if (self.pickedPicture)
                {
                    img.image = self.profileImage;
                }
                else if ([currentUser objectForKey:@"gymbudProfile"][@"profilePicture"])
                {
                    PFFile *theImage = [currentUser objectForKey:@"gymbudProfile"][@"profilePicture"];
                    NSLog(@"the image %@", theImage);
                    __weak UITableViewCell *weakCell = cell;
                    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                        NSLog(@"+++++++++ Loading image view with real data ++++++++");
                        UIImageView *img = (UIImageView*)[weakCell viewWithTag:1];
                        if (![UIImage imageWithData:data])
                        {
                            img.image = [UIImage imageNamed:@"yogaIcon.png"];
                            self.profileImage = img.image;
                        }
                        else
                        {
                            img.image = [UIImage imageWithData:data];
                            self.profileImage = img.image;
                        }
                        NSLog(@"image is %@", weakCell.imageView.image);
                    }];
                }

                UILabel *label = (UILabel*)[cell viewWithTag:2];
                label.textColor = [UIColor whiteColor];
                label.text = self.name;
                
                UILabel *label_gender = (UILabel*)[cell viewWithTag:3];
                
                if ([self.age length] > 0 && [self.gender length] > 0)
                    label_gender.text = [NSString stringWithFormat:@"Age: %@, Gender: %@", self.age, self.gender];
                else if ([self.age length] > 0)
                    label_gender.text = [NSString stringWithFormat:@"Age: %@", self.age];
                else if ([self.gender length] > 0)
                    label_gender.text = [NSString stringWithFormat:@"Gender: %@", self.gender];
                label_gender.textColor = [UIColor whiteColor];
            }
            else if (indexPath.row == 1)
            {
                // update click to use facebook profile
                cell.textLabel.text = @"Import Profile From Facebook";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
        }
            break;
        case 1:
        {
            if (indexPath.row==0)
            {
                UITextView *tv = (UITextView*)[cell viewWithTag:5];
                tv.delegate = self;
                if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"goals"])
                {
                    tv.text = [[PFUser currentUser] objectForKey:@"gymbudProfile"][@"goals"];
                    tv.textColor = [UIColor blackColor];
                
                }
                else
                {
                    tv.text = @"What are your weightlifting goals? Ex: I want to bench press 200 pounds as soon as possible";
                    tv.textColor = [UIColor lightGrayColor];
                }
                tv.backgroundColor = kGymBudLightBlue;
            }
            if (indexPath.row==1)
            {
                UITextView *tv = (UITextView*)[cell viewWithTag:5];
                tv.delegate = self;
                if ([[PFUser currentUser] objectForKey:@"gymbudProfile"][@"preferred"])
                {
                    tv.text = [[PFUser currentUser] objectForKey:@"gymbudProfile"][@"preferred"];
                    tv.textColor = [UIColor blackColor];
                }
                else
                {
                    tv.text = @"When are you generally free to work out? Ex: Mon/Wed 4-6, Thurs 9am-12.";
                    tv.textColor = [UIColor lightGrayColor];
                }
                tv.backgroundColor = kGymBudLightBlue;
            }
        }
            
        default:
            break;
    }
    cell.textLabel.font = [UIFont fontWithName:@"MagistralATT" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"MagistralATT" size:12];
    cell.textLabel.textColor = [UIColor whiteColor];

    UIColor * color = kGymBudLightBlue;
    cell.backgroundColor = color;
    

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Notifications stuff first:
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if([PFUser currentUser]) {
        [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    }
    [currentInstallation saveInBackground];

    // launch facebook fetch
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        // Set permissions required from the facebook user account
        NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
        
        NSLog(@"current user is: %@", [PFUser currentUser]);
        self.profileImage = [[UIImage alloc] init];
        
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:permissionsArray target:self selector:@selector(facebookFetchProfile)];

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

    }
    
}

-(void) facebookFetchProfile
{
    [self.HUD hide:YES];
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
                self.name = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
                self.gender = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                NSDate *birthday = [dateFormatter dateFromString:userData[@"birthday"]];
                NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                                   components:NSYearCalendarUnit
                                                   fromDate:birthday
                                                   toDate:[NSDate date]
                                                   options:0];
                NSInteger age = [ageComponents year];
                userProfile[@"age"] = [[NSNumber numberWithInt:(int)age] stringValue];
                self.age = [[NSNumber numberWithInt:(int)age] stringValue];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            // self.loadedImage = NO;
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection)
            {
                NSLog(@"Failed to download picture");
            }

            NSLog(@"user profile = %@", userProfile);
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] setObject:userData[@"name"] forKey:@"user_fb_name"];
            [[PFUser currentUser] saveInBackground];
            self.imageData = [[NSMutableData alloc] init];
            self.profileImage = [[UIImage alloc] init];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Your main thread code goes in here
                NSLog(@"Im on the main thread");
                [self.tableView reloadData];
            });
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
    [self.tableView reloadData];

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"What are your weightlifting goals? Ex: I want to bench press 200 pounds as soon as possible"] || [textView.text isEqualToString:@"When are you generally free to work out? Ex: Mon/Wed 4-6, Thurs 9am-12."])
    {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return FALSE;
    }
    return TRUE;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    UITableViewCell* cell = (UITableViewCell*)[textView superview];
    //UITableView* table = (UITableView *)[cell superview];
    NSIndexPath* pathOfTheCell = [self.tableView indexPathForCell:cell];
    NSInteger rowOfTheCell = [pathOfTheCell row];

    if ([textView.text isEqualToString:@"What are your weightlifting goals? Ex: I want to bench press 200 pounds as soon as possible"] || [textView.text isEqualToString:@"When are you generally free to work out? Ex: Mon/Wed 4-6, Thurs 9am-12."])
    {
        [self updateTextView:textView withIndex:rowOfTheCell];
    }
    else if ([textView.text length] == 0)
    {
        [self updateTextView:textView withIndex:rowOfTheCell];
    }
    [textView resignFirstResponder];
}

-(void)updateTextView:(UITextView*)tv withIndex:(NSInteger) index
{
    if (index == 0)
        tv.text = @"What are your weightlifting goals? Ex: I want to bench press 200 pounds as soon as possible";
    else
        tv.text = @"When are you generally free to work out? Ex: Mon/Wed 4-6, Thurs 9am-12.";
    
    tv.textColor = [UIColor lightGrayColor];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    EditPITableViewController *dest = [segue destinationViewController];
    dest.name = self.name;
    dest.gender = self.gender;
    dest.age = [self.age integerValue];
    dest.delegate = self;
}


- (void)cancelButtonHandler:(id)sender
{
    NSLog(@"cancel update profile");
    // unlink facebook user and clear facebook data
    if (self.didUpdateUsingFacebook)
    {
        [PFFacebookUtils unlinkUser:[PFUser currentUser]];
        NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
        [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
    }

    NSLog(@"current user %@", [PFUser currentUser]);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateProfileButtonHandler:(id)sender
{
    NSLog(@"update profile");
    NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];

    NSArray *cells = [self.tableView visibleCells];
    
    UITextField *tf = (UITextField*)[[cells objectAtIndex:2] viewWithTag:5];
    NSString *goal = tf.text;
    UITextField *tf2 = (UITextField*)[[cells objectAtIndex:3] viewWithTag:5];
    NSString *time = tf2.text;

    NSData *imageData = UIImageJPEGRepresentation(self.profileImage, 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"profilePicture.jpg" data:imageData];
    
    userProfile[@"profilePicture"] = imageFile;

    NSString *toastMessage = @"";
    
    // first get all strings from the tableview
    
    if([goal length] > 150) {
        toastMessage = [toastMessage stringByAppendingString:@"Goals max is 150 char. "];
    }
    else if([time isEqualToString:@""] || [time isEqualToString:@"When are you generally free to work out? Ex: Mon/Wed 4-6, Thurs 9am-12."]) {
        toastMessage = [toastMessage stringByAppendingString:@"Goals is mandatory. "];
    }
        
    if ([toastMessage length] > 0)
    {
        self.errorToast = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 40)];
        self.errorToast.backgroundColor = [UIColor orangeColor];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        textLabel.text = toastMessage;
        textLabel.textAlignment = NSTextAlignmentCenter;
        NSLog(@"textLabel text is: %@", textLabel.text);
        [self.errorToast addSubview:textLabel];
        UIApplication *app = [UIApplication sharedApplication];
        [app.keyWindow addSubview:self.errorToast];
    }

    userProfile[@"goals"] = goal;
    userProfile[@"preferred"] = time;
    userProfile[@"name"] = self.name;
    userProfile[@"age"] = self.age;
    userProfile[@"gender"] = self.gender;

    [[PFUser currentUser] setObject:userProfile forKey:@"gymbudProfile"];
    [[PFUser currentUser] saveInBackground];

    // update facebook profile in case facebook data was overwritten
    PFUser *currentUser = [PFUser currentUser];
    
    if ([currentUser objectForKey:@"profile"][@"name"])
        [[currentUser objectForKey:@"profile"] setObject:self.name forKey:@"name"];
    
    if ([currentUser objectForKey:@"profile"][@"age"])
        [[currentUser objectForKey:@"profile"] setObject:self.age forKey:@"age"];

    if ([currentUser objectForKey:@"profile"][@"gender"])
        [[currentUser objectForKey:@"profile"] setObject:self.gender forKey:@"gender"];

    [[PFUser currentUser] saveInBackground];

    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onEditPicture:(id)sender
{
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];

}

#pragma mark - ImagePicker Controller Delegate
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        self.profileImage = image;
        self.pickedPicture = YES;
    }
    [self.tableView reloadData];
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.loadedImage = YES;
    self.profileImage = [UIImage imageWithData:self.imageData];
    [self.tableView reloadData];
}

-(void) saveUserDataWithName:(NSString *)name userGender:(NSString *)gender withAge:(NSString*)age
{
    if ([name length] >0)
    {
        self.name = name;
    }
    if ([age length] >0)
    {
        self.age = age;
    }
    if ([gender length] >0)
    {
        self.gender = gender;
    }
    
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];

}
@end
