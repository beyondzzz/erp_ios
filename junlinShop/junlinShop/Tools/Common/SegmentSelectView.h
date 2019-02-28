//
//  SegmentSelectView.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentSelectViewDelegate <NSObject>

- (void)clickButton:(UIButton *)button AtIndex:(NSInteger)index;

@end

typedef enum {
    SegmentViewTypeNormal = 0,
    SegmentViewTypeClassfiy,
    SegmentViewTypeGoodsList,
    SegmentViewTypeTopImage,
    SegmentViewTypeBottonLine,
    SegmentViewTypeBuy
} SegmentViewType;

@interface SegmentSelectView : UIView

- (void)srcollToSelectedBtnAtIndex:(NSInteger)index;

@property (nonatomic, weak) id<SegmentSelectViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andImageNameArray:(NSArray *)imageArray byType:(SegmentViewType)segmentType;

@property (nonatomic, copy) void (^changeButtonTitle)(NSInteger index, NSString *title);

@end
