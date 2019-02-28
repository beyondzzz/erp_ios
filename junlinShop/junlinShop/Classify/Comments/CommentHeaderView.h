//
//  CommentHeaderView.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingBar.h"

@interface CommentHeaderView : UIView

@property (weak, nonatomic) IBOutlet RatingBar *totleRatingBar;
@property (weak, nonatomic) IBOutlet UILabel *scoreLab;
@property (weak, nonatomic) IBOutlet UILabel *totleCommentLab;
@property (weak, nonatomic) IBOutlet UIView *selectBackView;

@end
