//
//  CreateInviteTVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/10/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "CreateInviteTVC.h"
#import "GoActivityCVCell.h"
#import "GymBudConstants.h"
#import "CreateInviteCVCCell.h"
#import "LocationFinderVC.h"

@interface CreateInviteTVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *section1Label;
@property (weak, nonatomic) IBOutlet UILabel *section2Label;
@property (weak, nonatomic) IBOutlet UILabel *section3Label;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (nonatomic, strong) NSMutableArray *selectedBodyParts;


@end

@implementation CreateInviteTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedBodyParts = [[NSMutableArray alloc] initWithCapacity:[kGBBodyPartArray count]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight;
    if(indexPath.row == 1 && indexPath.section == 0) {
        cellHeight = 200;
    } else {
        cellHeight = 40;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, cellHeight)];
    // Configure the cell...
    
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0: // Label for body parts -- section1Label
                    self.section1Label.text = @"Select Up To 4 Body Parts";
                    [cell addSubview:self.section1Label];
                    break;
                case 1: // Collection View
                    cell = [[CreateInviteCVCCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"goActivityCell"];
                    [(CreateInviteCVCCell *)cell setCollectionViewDataSourceDelegate:self index:0];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            // Location Cell
            self.section2Label.text = @"Select a location";
            [cell addSubview:self.section2Label];
            break;
        case 2:
            switch(indexPath.row) {
                case 0: // Date Cell
                    self.section3Label.text = @"Select a date & time";
                    [cell addSubview:self.section3Label];
                    break;
                case 1: // Invite Friends button
                    self.button1.titleLabel.text = @"Invite Friends (SMS)";
                    [cell addSubview:self.button1];
                    break;
                case 2: // Create event button
                    self.button2.titleLabel.text = @"Create an Event (Public)";
                    [cell addSubview:self.button2];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0: // Label for body parts -- section1Label
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                case 1: // Collection View
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            // Location Cell
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LocationFinderVC"
                                                                 bundle:[NSBundle mainBundle]];
            LocationFinderVC *locationFinder = [storyboard instantiateViewControllerWithIdentifier:@"LocationFinderVC"];            [self.navigationController pushViewController:locationFinder animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
            break;
        case 2:
            switch(indexPath.row) {
                case 0: // Date Cell
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                case 1: // Invite Friends button
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                case 2: // Create event button
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [kGBBodyPartArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoActivityCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goActivityCell" forIndexPath:indexPath];
    
    if([self.selectedBodyParts containsObject:indexPath]) {
        cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:indexPath.row]];
    } else {
        cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:indexPath.row]];
    }
    cell.goActivityTextLabel.text = [kGBBodyPartArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.goActivityTextLabel.font = [UIFont fontWithName:@"MagistralATT-Bold" size:18];
    cell.goActivityTextLabel.textColor = kGymBudGold;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.selectedBodyParts count] < 4) {
        [self.selectedBodyParts addObject:indexPath];
        GoActivityCVCell *cell = (GoActivityCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //        cell.backgroundColor = [UIColor whiteColor];
        //        cell.layer.cornerRadius = 30;
        //        cell.layer.masksToBounds = YES;
        cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesSelArray objectAtIndex:indexPath.row]];
        
    } else {
        // DO nothing, we don't want to select more than 4
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select up to 4 Body Parts" message:@"You have tried to select more than 4" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedBodyParts removeObject:indexPath];
    GoActivityCVCell *cell = (GoActivityCVCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor clearColor];
    cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGBBodyPartImagesArray objectAtIndex:indexPath.row]];
}


@end
