//
//  ActiveQuanCollectionCell.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ActiveQuanCollectionCell.h"

@implementation ActiveQuanCollectionCell

- (void)setDataWithDic:(NSDictionary *)dic {
    _countLab.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"price"]];
    _titleLab.text = [NSString stringWithFormat:@"满%@元可用", [dic objectForKey:@"useLimit"]];
    
//    YWWeakSelf;
    [[[_getBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:userID forKey:@"userId"];
        [dict setValue:[dic objectForKey:@"id"] forKey:@"couponId"];
        
        [HttpTools Post:kAppendUrl(YWGetCouponString) parameters:dict success:^(id responseObject) {
            [SVProgressHUD showInfoWithStatus:[responseObject objectForKey:@"resultData"]];
        } failure:^(NSError *error) {
            //            [SVProgressHUD showErrorWithStatus:@"领取失败"];
        }];
        
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_backView setRadius:5.f];
    [_getBtn setBorder:[UIColor whiteColor] width:1.f radius:5.f];
    // Initialization code
}

@end
