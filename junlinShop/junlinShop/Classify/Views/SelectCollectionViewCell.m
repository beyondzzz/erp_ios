//
//  SelectCollectionViewCell.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/25.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SelectCollectionViewCell.h"

@implementation SelectCollectionViewCell

- (void)setBrandStr:(NSString *)brandStr isSelected:(BOOL)isSelected {
    _brandLab.text = brandStr;
    if (isSelected) {
        _selectedImageView.hidden = NO;
        _brandLeftConstraint.constant = 20;
        [_backView setBorder:kBackGreenColor width:1 radius:5.f];
        _backView.backgroundColor = kBackViewColor;
        _brandLab.textColor = kBackGreenColor;
    } else {
        _selectedImageView.hidden = YES;
        _brandLeftConstraint.constant = 6;
        [_backView setBorder:kBackGrayColor width:1 radius:5.f];
        _backView.backgroundColor = kBackGrayColor;
        _brandLab.textColor = kBlackTextColor;
        
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
