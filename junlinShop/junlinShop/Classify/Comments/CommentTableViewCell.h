//
//  CommentTableViewCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingBar.h"

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLab;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet RatingBar *ratingBar;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIView *imageBackView;

@property (nonatomic, copy) void (^refreshBlock)(void);

- (void)setDataWithDic:(NSDictionary *)dic;
+ (CGFloat)getCellHeightWithDic:(NSDictionary *)dic;

@end
