//
//  CommentDetailTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/3/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingBar.h"

@interface CommentDetailTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet RatingBar *ratingBar;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIView *imageBackView;

@property (nonatomic) BOOL isComeFromOrder;

- (void)setDataWithDic:(NSDictionary *)dic;
+ (CGFloat)getCellHeightWithDic:(NSDictionary *)dic;

@end
