//
//  UIButton+YWExtension.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MKButtonEdgeInsetsStyle) {
    MKButtonEdgeInsetsStyleTop, // image在上，label在下
    MKButtonEdgeInsetsStyleLeft, // image在左，label在右
    MKButtonEdgeInsetsStyleBottom, // image在下，label在上
    MKButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (YWExtension)

/**
 创建只含有文字的button
 */
+ (instancetype)creatBtnWithFrame:(CGRect)frame title:(NSString *)title font:(CGFloat)font titleColor:(UIColor *)titleColor highlightColor:(UIColor *)highlightColor taret:(id)target action:(SEL)action;

/**
 创建只有图片的button
 */
+ (instancetype)creatBtnWithFrame:(CGRect)frame imgName:(NSString *)imgName highlightImgName:(NSString *)highlightImgName taret:(id)target action:(SEL)action;

/**
 创建既有文字又有图片的button
 */
+ (instancetype)creatBtnWithFrame:(CGRect)frame title:(NSString *)title font:(CGFloat)font titleColor:(UIColor *)titleColor highlightColor:(UIColor *)highlightColor imgName:(NSString *)imgName highlightImgName:(NSString *)highlightImgName taret:(id)target action:(SEL)action;

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;


@end
