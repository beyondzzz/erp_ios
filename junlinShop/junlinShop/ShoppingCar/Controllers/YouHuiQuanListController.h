//
//  YouHuiQuanListController.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface YouHuiQuanListController : BaseViewController

@property (nonatomic, strong) NSArray *goodsArray;
@property (nonatomic) BOOL isSelectYouHuiQuan;
@property (nonatomic,assign) CGFloat realityPrice;

@property (nonatomic, copy) void (^selectedYouHuiQuan)(NSDictionary *dict);

@end
