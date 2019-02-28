//
//  CommentDetailTableCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/3/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CommentDetailTableCell.h"

@implementation CommentDetailTableCell

- (void)setDataWithDic:(NSDictionary *)dic {
    
    NSNumber *score = nil;
    NSString *contentStr = nil;
    NSString *goodsImageUrl = nil;
    NSArray *commentImageArr = nil;
    
    if (_isComeFromOrder) {
        goodsImageUrl = [dic objectForKey:@"goodsCoverUrl"];
        
        NSDictionary *orderDetail = [dic objectForKey:@"goodsEvaluation"];
        score = [orderDetail objectForKey:@"score"];
        contentStr = [orderDetail objectForKey:@"evaluationContent"];
        commentImageArr = [orderDetail objectForKey:@"evaluationPics"];
    } else {
        score = [dic objectForKey:@"score"];
        contentStr = [dic objectForKey:@"evaluationContent"];
        NSDictionary *orderDetail = [dic objectForKey:@"orderDetail"];
        if ([orderDetail isKindOfClass:[NSDictionary class]]) {
            goodsImageUrl = [orderDetail objectForKey:@"goodsCoverUrl"];
        }
        commentImageArr = [dic objectForKey:@"evaluationPics"];
    }
    [_ratingBar setImageDeselected:@"emptyStar" halfSelected:@"halfStar" fullSelected:@"fullStar" andDelegate:nil];
    _ratingBar.isIndicator = YES;
    
    [_ratingBar displayRating:[score floatValue]];
    
    _contentLab.text = contentStr;
    
    if (goodsImageUrl) {
        [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl(goodsImageUrl)] placeholderImage:kDefaultImage];
    }
    
    if (commentImageArr.count) {
        _imageBackView.hidden = NO;
        for (UIView *view in _imageBackView.subviews) {
            view.hidden = YES;
        }
        
        for (int i = 0; i < commentImageArr.count; i ++) {
            UIImageView *imageView = [_imageBackView viewWithTag:i + 1000];
            imageView.hidden = NO;
            NSString *imageURL = kAppendUrl([commentImageArr[i] objectForKey:@"picUrl"]);
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:kDefaultImage];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
            tapGesture.delegate = self;
            [[[tapGesture rac_gestureSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
                NSInteger index = x.view.superview.tag - 1000;
                //                CircleImageView *circleView = [[CircleImageView alloc] init];
                //                NSMutableArray *imageurlArr = [NSMutableArray array];
                //                for (NSDictionary *imageDic in model.albums) {
                //                    [imageurlArr addObject:[imageDic objectForKey:@"imgUrl"]];
                //                }
                //                [circleView setImageArray:imageurlArr andIndex:index];
            }];
            [imageView addGestureRecognizer:tapGesture];
        }
    } else {
        _imageBackView.hidden = YES;
    }
}

+ (CGFloat)getCellHeightWithDic:(NSDictionary *)dic {
    NSString *contentStr = nil;
    
    NSDictionary *orderDetail = [dic objectForKey:@"goodsEvaluation"];
    if (orderDetail) {
        contentStr = [orderDetail objectForKey:@"evaluationContent"];
    } else {
        contentStr = [dic objectForKey:@"evaluationContent"];
    }
    
    NSArray *picArr = [dic objectForKey:@"evaluationPics"];
    if (picArr == nil) {
        NSDictionary *orderDetail = [dic objectForKey:@"goodsEvaluation"];
        picArr = [orderDetail objectForKey:@"evaluationPics"];
    }
    
    CGFloat cellHeight = 0;
    CGFloat textHeight = [ASHString LabHeightWithString:contentStr font:[UIFont systemFontOfSize:15.f] andRectWithSize:CGSizeMake(kIphoneWidth - 30, kIphoneHeight)];
    CGFloat labelHeight = 0;
    CGFloat imageHeight = 0;
    
    if (picArr.count > 0) {
        imageHeight = (kIphoneWidth - 24) * 70 / 360;
    }
    //    if (textHeight > 55) {
    //        labelHeight = textHeight + 6;
    //        cellHeight = labelHeight + imageHeight + 60;
    //    } else {
    labelHeight = textHeight + 8;
    cellHeight = labelHeight + imageHeight + 90;
    //    }
    return cellHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
