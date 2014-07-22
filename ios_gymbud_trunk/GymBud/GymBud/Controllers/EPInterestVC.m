//
//  EPInterestVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/15/14.
//  Copyright (c) 2014 Benjamin Hendricks. All rights reserved.
//

#import "EPInterestVC.h"

@interface EPInterestVC ()

@property (strong, nonatomic) NSMutableArray *interests;
@property int interestNumber;

@end

@implementation EPInterestVC
@synthesize interests;
@synthesize interestNumber;

- (void) setCurrentInterest: (int) interest {
    NSLog(@"current interest was : %d", interest);
    self.interestNumber = interest;
}
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
    interests = [[NSMutableArray alloc] init];
    [interests addObject:@"Aerobics"];
    [interests addObject:@"Basketball"];
    [interests addObject:@"Crossfit"];
    [interests addObject:@"Running"];
    [interests addObject:@"Swimming"];
    [interests addObject:@"Weightlifting"];
    [interests addObject:@"Yoga"];
    NSLog(@"view did load epinterestvc delegate is: %@", _delegate);

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select row at index path");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.textLabel.text);
    [self.delegate editProfileInterestViewController:self didAddInterest:cell.textLabel.text forInterest:interestNumber];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [interests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"interest" forIndexPath:indexPath];
 
 // Configure the cell...
     cell.textLabel.text = [interests objectAtIndex:indexPath.row];
 
 return cell;
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
