//
//  DropdownTagSelectView.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DropdownTagViewTypeCollection = 0,
    DropdownTagViewTypeTable
} DropdownTagViewType;

typedef void (^BrandComplete)(NSArray *brandArray);
typedef void (^TableSelectComplete)(NSString *selectStr);
@interface DropdownTagSelectView : UIView

+ (instancetype)initWithDataArray:(NSArray *)dataArray andType:(DropdownTagViewType)type andCompleteBlock:(BrandComplete)complete orTableSelectComplete:(TableSelectComplete)tableComplete;


@end
