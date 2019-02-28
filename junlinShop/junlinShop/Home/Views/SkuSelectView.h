//
//  SkuSelectView.h
//  ShopApp
//
//  Created by jianxuan on 2018/1/15.
//  Copyright © 2018年 Sorry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkuSelectView : UIView

@property (nonatomic, strong) NSArray *skusArr;
@property (nonatomic, strong) NSDictionary *skuDic;
@property (nonatomic) NSInteger selectNum;

@property (nonatomic) NSInteger type;
@property (nonatomic, copy) void (^selectedSkuByShop)(NSDictionary *skuDic, NSInteger selectNum, NSInteger skuType); //1 加入购物车 2立即购买 3无

//@property (nonatomic, copy) void (^selectedSku)(NSDictionary *skuDic, NSInteger selectNum);

@end
