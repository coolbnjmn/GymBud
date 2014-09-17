//
//  GBEventsFilterViewController.m
//  GymBud
//
//  Created by Benjamin Hendricks on 9/16/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "GBEventsFilterViewController.h"
#import "GymBudConstants.h"
#import "GoActivityCVCell.h"

@interface GBEventsFilterViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *activityCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *activityCollectionViewFlowLayout;

@end

static NSString * const reuseIdentifier = @"goActivityCell";

@implementation GBEventsFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    self.activityCollectionView.dataSource = self;
    self.activityCollectionView.delegate = self;
    [self.activityCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.activityCollectionView registerNib:[UINib nibWithNibName:@"GoActivityCVCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseIdentifier];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [kGymBudActivities count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoActivityCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    cell.goActivityPictureImaveView.image = [UIImage imageNamed:[kGymBudActivityIconMapping objectForKey:[kGymBudActivities objectAtIndex:index]]];
    cell.goActivityTextLabel.text = [kGymBudActivities objectAtIndex:index];
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}


@end
