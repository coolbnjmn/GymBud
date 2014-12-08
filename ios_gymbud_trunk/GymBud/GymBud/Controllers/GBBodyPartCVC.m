//
//  GBBodyPartCVC.m
//  GymBud
//
//  Created by Benjamin Hendricks on 8/30/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GBBodyPartCVC.h"
#import "GoActivityCVCell.h"
#import "GymBudConstants.h"
#import "GoActivityChosenVC.h"
#import "Mixpanel.h"

@interface GBBodyPartCVC ()

@property (nonatomic, strong) NSMutableArray *selectedBodyParts;
@end

@implementation GBBodyPartCVC

static NSString * const reuseIdentifier = @"goActivityCell";

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
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"GoActivityCVCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseIdentifier];
    UIColor * color = kGymBudLightBlue;
    
    UIColor *lightOp = kGymBudLightBlue;
    UIColor *darkOp = kGymBudDarkBlue;
    
    // Create the gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // Set colors
    gradient.colors = [NSArray arrayWithObjects:
                       [UIColor whiteColor].CGColor,
                       (id)lightOp.CGColor,
                       (id)darkOp.CGColor,
                       nil];
    
    // Set bounds
    gradient.frame = self.view.bounds;

//    gradient.anchorP;
    // Add the gradient to the view
    self.collectionView.backgroundView = [[UIView alloc] init];
    [self.collectionView.backgroundView.layer insertSublayer:gradient atIndex:0];
//    self.collectionView.backgroundColor = color;
    
    
    self.navigationItem.title = @"Select Body Part(s)";
    [self.collectionView setAllowsMultipleSelection:YES];
    self.selectedBodyParts = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(continueWithBodyParts:)];
    self.navigationItem.rightBarButtonItem = continueButton;
    // Do any additional setup after loading the view.
    
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

#pragma mark <UICollectionViewDataSource>

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
    GoActivityCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
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

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	
}
*/

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 150);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 5, 10, 5);
}

- (void) continueWithBodyParts:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GoActivity" bundle:nil];
    GoActivityChosenVC *vc = [sb instantiateViewControllerWithIdentifier:@"GoActivityChosenVC"];
    vc.activity = [kGymBudActivities objectAtIndex:5]; // TODO: fix hard coded for Weightlifting
    vc.bodyPartIndices = self.selectedBodyParts;
    [self.navigationController pushViewController:vc animated:YES];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"GBBodyPartCVC Next" properties:@{
                                                  }];
}
@end
