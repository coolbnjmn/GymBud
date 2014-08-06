//
//  GoActivityCreateEventVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/4/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GoActivityCreateEventVC.h"

@interface GoActivityCreateEventVC ()

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *namesTextView;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createEventButtonHandler:(id) sender {
    // need to parse out all the elements into a parse object
    // and return to a special page.
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
