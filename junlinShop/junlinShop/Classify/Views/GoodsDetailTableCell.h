//
//  GoodsDetailTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftLab;
@property (weak, nonatomic) IBOutlet UILabel *activeLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabConstraint;

- (void)setUIHiddenAtIndex:(NSInteger)index;

@end
