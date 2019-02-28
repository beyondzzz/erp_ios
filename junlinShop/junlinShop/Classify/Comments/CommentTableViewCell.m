//
//  CommentTableViewCell.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/24.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "CircleImageView.h"
#import "HZPhotoBrowser.h"


@implementation CommentTableViewCell

- (void)setDataWithDic:(NSDictionary *)dic; {
    
    [_ratingBar setImageDeselected:@"emptyStar" halfSelected:@"halfStar" fullSelected:@"fullStar" andDelegate:nil];
    _ratingBar.isIndicator = YES;
    
    NSNumber *score = [dic objectForKey:@"score"];
    [_ratingBar displayRating:[score floatValue]];
    
    _contentLab.text = [dic objectForKey:@"evaluationContent"];
    
    NSDictionary *userDic = [dic objectForKey:@"user"];
    _nameLab.text = [userDic objectForKey:@"name"];
    if ([[userDic objectForKey:@"isVip"] integerValue] == 1) {
        _vipImageView.hidden = NO;
    } else {
        _vipImageView.hidden = YES;
    }
    
    if ([ASHValidate isMobileNumber:[userDic objectForKey:@"phone"]]) {
        NSString *replaceStr = [[userDic objectForKey:@"phone"]  stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        _phoneNumLab.text = replaceStr;
    } else {
        _phoneNumLab.text = [userDic objectForKey:@"phone"];
    }
    
    _timeLab.text = [ASHString jsonDateToString:[dic objectForKey:@"evaluationTime"] withFormat:@"yyyy-MM-dd"];
//    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:[UIImage imageNamed:@"placeHolder_Image"]];
    
//    _lookAllBtn.hidden = !model.isShowBtn;
//    [[[_lookAllBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        model.isShowAll = !model.isShowAll;
//        if (model.isShowAll) {
//            model.isShowBtn = NO;
//        }
//        self.refreshBlock();
//    }];
    
    NSArray *picArr = [dic objectForKey:@"evaluationPics"];
    if (picArr.count) {
        _imageBackView.hidden = NO;
        for (UIView *view in _imageBackView.subviews) {
            view.hidden = YES;
        }
        
        for (int i = 0; i < picArr.count; i ++) {
            UIImageView *imageView = [_imageBackView viewWithTag:i + 1000];
            imageView.hidden = NO;
            imageView.userInteractionEnabled = YES;
            NSString *imageURL = kAppendUrl([picArr[i] objectForKey:@"picUrl"]);
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:kDefaultImage];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
            tapGesture.delegate = self;
            [[[tapGesture rac_gestureSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
//                NSInteger index = x.view.superview.tag - 1000;
//
                NSMutableArray *imageurlArr = [NSMutableArray array];
                for (NSDictionary *imageDic in picArr) {
                    [imageurlArr addObject:kAppendUrl([imageDic objectForKey:@"picUrl"])];
                }

                
                HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
                browser.isFullWidthForLandScape = YES;
                browser.isNeedLandscape = YES;
                browser.currentImageIndex = 0;
                browser.imageArray = imageurlArr;
                [browser show];
                
//                CircleImageView *circleView = [[CircleImageView alloc] init];
//                NSMutableArray *imageurlArr = [NSMutableArray array];
//                for (NSDictionary *imageDic in picArr) {
//                    [imageurlArr addObject:kAppendUrl([imageDic objectForKey:@"picUrl"])];
//                }
//       [imageurlArr addObject:@"http://cc.cocimg.com/api/uploads/180813/da25305b21ac969e8cae04f9efbafdf0.png"];
//                [circleView setImageArray:imageurlArr andIndex:index];
            }];
            
            [imageView addGestureRecognizer:tapGesture];
        }
    } else {
        _imageBackView.hidden = YES;
    }
}

+ (CGFloat)getCellHeightWithDic:(NSDictionary *)dic {
    CGFloat cellHeight = 0;
    CGFloat textHeight = [ASHString LabHeightWithString:[dic objectForKey:@"evaluationContent"] font:[UIFont systemFontOfSize:15.f] andRectWithSize:CGSizeMake(kIphoneWidth - 30, kIphoneHeight)];
    CGFloat labelHeight = 0;
    CGFloat imageHeight = 0;
    NSArray *picArr = [dic objectForKey:@"evaluationPics"];
    if (picArr.count > 0) {
        imageHeight = (kIphoneWidth - 24) * 70 / 360;
    }
//    if (textHeight > 55) {
//        labelHeight = textHeight + 6;
//        cellHeight = labelHeight + imageHeight + 60;
//    } else {
        labelHeight = textHeight + 8;
        cellHeight = labelHeight + imageHeight + 85;
//    }
    return cellHeight;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
