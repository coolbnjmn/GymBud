//
//  CreateInviteCVCCell.h
//  GymBud
//
//  Created by Benjamin Hendricks on 12/10/14.
//  Copyright (c) 2014 GymBud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateInviteCVCCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
