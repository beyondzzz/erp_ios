//
//  AddNormalInvoiceView.h
//  junlinShop
//
//  Created by jianxuan on 2018/3/9.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNormalInvoiceView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *numField;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (nonatomic, copy) void (^completeBlock)(void);

- (void)initData;
- (void)initDataWithDic:(NSDictionary *)unitDic;

@end
