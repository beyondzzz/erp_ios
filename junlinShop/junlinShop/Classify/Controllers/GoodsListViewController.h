//
//  GoodsListViewController.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface GoodsListViewController : BaseViewController

@property (nonatomic, strong) NSArray *classifArray;
@property (nonatomic, strong) NSString *searchStr;
@property (nonatomic, strong) NSNumber *classifId;
@property (nonatomic, assign) BOOL isShowRightBtn;

@end
