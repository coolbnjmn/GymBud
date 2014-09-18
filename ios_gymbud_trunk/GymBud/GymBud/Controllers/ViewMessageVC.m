//
//  ViewMessageVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/20/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "ViewMessageVC.h"
#import "MessageUserVC.h"

@interface ViewMessageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *fromImage;
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageContents;

@end

@implementation ViewMessageVC

@synthesize activity;
@synthesize fromImage;
@synthesize whenLabel;
@synthesize messageContents;


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
    if(!activity) {
        NSLog(@"something went wrong");
    } else {
        if([activity objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"]) {
            PFFile *theImage = [activity objectForKey:@"fromUser"][@"gymbudProfile"][@"profilePicture"];
            __weak ViewMessageVC *weakSelf = self;
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                NSLog(@"+++++++++ Loading image view with real data ++++++++");
                weakSelf.fromImage.image = [UIImage imageWithData:data];
            }];
        } else {
            fromImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[activity objectForKey:@"fromUser"] objectForKey:@"profile"] objectForKey:@"pictureURL"]]]];
        }
        
        self.navigationItem.title = [[[activity objectForKey:@"fromUser"] objectForKey:@"profile"] objectForKey:@"name"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        whenLabel.text = [dateFormatter stringFromDate:[activity createdAt]];
        NSLog(@"%@", activity);
        messageContents.text = [activity objectForKey:@"content"];
    }
    
    // set up reply and back buttons here
    UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStyleBordered target:self action:@selector(replyToMessage:)];
    self.navigationItem.rightBarButtonItem = replyButton;
}

- (void)replyToMessage:(id) sender {
    // go to messageuservc    
    NSLog(@"about to reply to message user");
    MessageUserVC *controller = [[MessageUserVC alloc] initWithNibName:nil bundle:nil];
    controller.user = [activity objectForKey:@"fromUser"];
    [self.navigationController pushViewController:controller animated:YES]; // or use presentViewController if you're using modals
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
