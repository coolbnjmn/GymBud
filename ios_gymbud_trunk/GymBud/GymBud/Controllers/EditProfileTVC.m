//
//  EditProfileTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/15/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "EditProfileTVC.h"
#import "EPInterestVC.h"

@interface EditProfileTVC ()
@property (weak, nonatomic) IBOutlet UILabel *interest1;
@property (weak, nonatomic) IBOutlet UILabel *interest2;
@property (weak, nonatomic) IBOutlet UILabel *interest3;
@property (weak, nonatomic) IBOutlet UITextView *backgroundTextView;
@property (weak, nonatomic) IBOutlet UITextView *achievementsTextView;
@property (weak, nonatomic) IBOutlet UITextView *goalsTextView;

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
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"background"]) {
        self.backgroundTextView.text = [currentUser objectForKey:@"gymbudProfile"][@"background"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"achievements"]) {
        self.achievementsTextView.text = [currentUser objectForKey:@"gymbudProfile"][@"achievements"];
    }
    
    if ([currentUser objectForKey:@"gymbudProfile"][@"goals"]) {
        self.goalsTextView.text = [currentUser objectForKey:@"gymbudProfile"][@"goals"];
    }}

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


- (void)cancelButtonHandler:(id)sender {
    NSLog(@"cancel update profile");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateProfileButtonHandler:(id)sender {
    NSLog(@"update profile");
    NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
    
    userProfile[@"interest1"] = self.interest1.text;
    userProfile[@"interest2"] = self.interest2.text;
    userProfile[@"interest3"] = self.interest3.text;
    userProfile[@"background"] = self.backgroundTextView.text;
    userProfile[@"achievements"] = self.achievementsTextView.text;
    userProfile[@"goals"] = self.goalsTextView.text;

    
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

@end
