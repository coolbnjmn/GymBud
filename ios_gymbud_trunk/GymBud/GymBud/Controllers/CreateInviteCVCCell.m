//
//  CreateInviteCVCCell.m
//  GymBud
//
//  Created by Benjamin Hendricks on 12/10/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import "CreateInviteCVCCell.h"
#import "GoActivityCVCell.h"
#import "GymBudConstants.h"

@implementation CreateInviteCVCCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
    layout.itemSize = CGSizeMake(120, 120);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GoActivityCVCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"goActivityCell"];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.allowsMultipleSelection = YES;
    [self.contentView addSubview:self.collectionView];
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    UIColor *lightOp = kGymBudLightBlue;
    UIColor *darkOp = kGymBudDarkBlue;
    
    // Create the gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // Set colors
    gradient.colors = [NSArray arrayWithObjects:
                       (id)kGymBudGrey.CGColor,
                       (id)lightOp.CGColor,
                       nil];
    
    // Set bounds
    gradient.frame = self.contentView.bounds;
    
    //    gradient.anchorP;
    // Add the gradient to the view
    self.collectionView.backgroundView = [[UIView alloc] init];
    [self.collectionView.backgroundView.layer insertSublayer:gradient atIndex:0];
    self.collectionView.frame = self.contentView.bounds;
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}
@end
