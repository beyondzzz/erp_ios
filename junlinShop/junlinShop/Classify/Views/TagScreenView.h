//
//  TagScreenView.h
//  simple
//
//  Created by jianxuan on 2017/11/20.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsTypeSelectModel.h"

typedef void (^ScreenComplete)(GoodsTypeSelectModel *selectModel);
@interface TagScreenView : UIView

+ (instancetype)initWithDataArray:(NSArray *)dataArray andGoodTypeModel:(GoodsTypeSelectModel *)typeModel andCompleteBlock:(ScreenComplete)complete;

@end
