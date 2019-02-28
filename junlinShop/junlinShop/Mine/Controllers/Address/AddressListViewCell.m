//
//  AddressListViewCell.m
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "AddressListViewCell.h"

@implementation AddressListViewCell

- (void)setDataWithModel:(AddressModel *)model completeBlock:(void (^)(AddressModel *finishModel, NSInteger btnTag))completeBlock {
    if (model.isCommonlyUsed.intValue) {
        _morenBtn.selected = YES;
    } else {
        _morenBtn.selected = NO;
    }
    
    _nameLab.text = model.consigneeName;
    _addressLab.text = [NSString stringWithFormat:@"%@ %@", model.region, model.detailedAddress];
    _phoneLab.text = model.consigneeTel;
    
    
    [[[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        completeBlock(model, x.tag);
    }];
    
    [[[_morenBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = YES;
        completeBlock(model, x.tag);
    }];
    
    [[[_editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        completeBlock(model, x.tag);
    }];
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
