//
//  PCInterestTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 7/26/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "PCInterestTVC.h"
#import "GymBudConstants.h"


@interface PCInterestTVC ()

@end

@implementation PCInterestTVC

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
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select row at index path");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.textLabel.text);
    [self.delegate didSelectActivity:cell.textLabel.text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [kGymBudActivities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"interest" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [kGymBudActivities objectAtIndex:indexPath.row];
    
    return cell;
}


@end
