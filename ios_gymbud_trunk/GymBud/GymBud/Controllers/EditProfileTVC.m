//
//  EditProfileTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/15/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "EditProfileTVC.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface EditProfileTVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *interest1;
@property (weak, nonatomic) IBOutlet UILabel *interest2;
@property (weak, nonatomic) IBOutlet UILabel *interest3;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *profileAge;
@property (weak, nonatomic) IBOutlet UILabel *profileGender;
@property (weak, nonatomic) IBOutlet UITextView *profileGoals;
@property (weak, nonatomic) IBOutlet UITextView *profileAchievements;
@property (weak, nonatomic) IBOutlet UITextView *profileOrgs;
@property (weak, nonatomic) IBOutlet UITextView *profileAbout;


@property (strong, nonatomic) NSMutableData* imageData;
@end

@implementation EditProfileTVC

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"viewDidLoad EDITPROFILETVC");
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonHandler:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(updateProfileButtonHandler:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser objectForKey:@"gymbudProfile"][@"interest1"]) {
        self.interest1.text = [currentUser objectForKey:@"gymbudProfile"][@"interest1"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"interest2"]) {
        self.interest2.text = [currentUser objectForKey:@"gymbudProfile"][@"interest2"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"interest3"]) {
        self.interest3.text = [currentUser objectForKey:@"gymbudProfile"][@"interest3"];
    }

    if ([currentUser objectForKey:@"gymbudProfile"][@"goals"]) {
        self.profileGoals.text = [currentUser objectForKey:@"gymbudProfile"][@"goals"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"achievements"]) {
        self.profileAchievements.text = [currentUser objectForKey:@"gymbudProfile"][@"achievements"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"organizations"]) {
        self.profileOrgs.text = [currentUser objectForKey:@"gymbudProfile"][@"organizations"];
    }
    
    if([currentUser objectForKey:@"gymbudProfile"][@"about"]) {
        self.profileAbout.text = [currentUser objectForKey:@"gymbudProfile"][@"about"];
    }
    if ([currentUser objectForKey:@"profile"][@"name"]) {
        self.profileName.text = [currentUser objectForKey:@"profile"][@"name"];
    }
    
    if ([currentUser objectForKey:@"profile"][@"age"]) {
        self.profileAge.text = [currentUser objectForKey:@"profile"][@"age"];
    }
    
    if ([currentUser objectForKey:@"profile"][@"gender"]) {
        self.profileGender.text = [currentUser objectForKey:@"profile"][@"gender"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"profilePicture"]) {
        PFFile *theImage = [currentUser objectForKey:@"gymbudProfile"][@"profilePicture"];
        __weak EditProfileTVC *weakSelf = self;
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
}

- (void) editProfileInterestViewController:(EPInterestVC *)vc didAddInterest:(NSString *)interest forInterest:(int) interestNumber {
    NSLog(@"delgate worked: interest is %@", interest);

    if(interestNumber == 0) {
        self.interest1.text = interest;
    } else if(interestNumber == 1) {
        self.interest2.text = interest;
    } else {
        self.interest3.text = interest;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editProfileBasicInfoViewController:(EPBasicInfoVC *)vc didSetValues:(NSString *)name age:(NSString *)age andGender:(NSString *)gender {
    NSLog(@"delegate worked: stuff is here");
    self.profileName.text = name;
    self.profileAge.text = age;
    self.profileGender.text = gender;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonHandler:(id)sender {
    NSLog(@"cancel update profile");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateProfileButtonHandler:(id)sender {
    NSLog(@"update profile");
    NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];

    if([self.profileGoals.text length] > 150 || [self.profileAchievements.text length] > 250 || [self.profileOrgs.text length] > 100 || [self.profileAbout.text length] > 300) {
        // show view here
        return;
    }
    userProfile[@"interest1"] = self.interest1.text;
    userProfile[@"interest2"] = self.interest2.text;
    userProfile[@"interest3"] = self.interest3.text;
    userProfile[@"goals"] = self.profileGoals.text;
    userProfile[@"achievements"] = self.profileAchievements.text;
    userProfile[@"organizations"] = self.profileOrgs.text;
    userProfile[@"about"] = self.profileAbout.text;
    userProfile[@"name"] = self.profileName.text;
    userProfile[@"age"] = self.profileAge.text;
    userProfile[@"gender"] = self.profileGender.text;
    
    NSData *imageData = UIImageJPEGRepresentation(self.profilePicture.image, 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"profilePicture.jpg" data:imageData];
    
    userProfile[@"profilePicture"] = imageFile;
    
    [[PFUser currentUser] setObject:userProfile forKey:@"gymbudProfile"];
    [[PFUser currentUser] saveInBackground];

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 1;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"Interest 1"]) {
        [[segue destinationViewController] setCurrentInterest:0];
        EPInterestVC *destVC = [segue destinationViewController];
        destVC.delegate = self;
    } else if([[segue identifier] isEqualToString:@"Interest 2"]) {
        [[segue destinationViewController] setCurrentInterest:1];
        EPInterestVC *destVC = [segue destinationViewController];
        destVC.delegate = self;
    } else if([[segue identifier] isEqualToString:@"Interest 3"]) {
        [[segue destinationViewController] setCurrentInterest:2];
        EPInterestVC *destVC = [segue destinationViewController];
        destVC.delegate = self;
    }
}

- (IBAction)editProfilePicture:(id)sender {
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType =
//    UIImagePickerControllerSourceTypeCamera;
    UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker
                       animated:YES completion:nil];
}

- (IBAction)editUserInfo:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EditProfile" bundle:nil];
    EPBasicInfoVC *vc = [sb instantiateViewControllerWithIdentifier:@"EPBasicInfoVC"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    [vc setCurrentValues:self.profileName.text age:self.profileAge.text andGender:self.profileGender.text];

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
@end
