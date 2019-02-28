//
//  SetCommentTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingBar.h"
#import "SetCommentModel.h"

@interface SetCommentTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet RatingBar *ratingBar;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *codeCountLab;
@property (weak, nonatomic) IBOutlet UILabel *placeHoulderLab;

@property (weak, nonatomic) IBOutlet UIView *imageBackView;

//@property (nonatomic, strong) NSMutableDictionary *commentDic;

- (void)setDataWithModel:(SetCommentModel *)model;

@end
