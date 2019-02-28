//
//  UIButton+YWExtension.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "UIButton+YWExtension.h"

@implementation UIButton (YWExtension)
/**
 创建只含有文字的button
 */
+ (instancetype)creatBtnWithFrame:(CGRect)frame title:(NSString *)title font:(CGFloat)font titleColor:(UIColor *)titleColor highlightColor:(UIColor *)highlightColor taret:(id)target action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    if (font) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:font]];
    }
    if (titleColor) {
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    }else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (highlightColor) {
        [button setTitleColor:highlightColor forState:UIControlStateHighlighted];
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/**
 创建只有图片的button
 */
+ (instancetype)creatBtnWithFrame:(CGRect)frame imgName:(NSString *)imgName highlightImgName:(NSString *)highlightImgName taret:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    if (highlightImgName) {
        [button setImage:[UIImage imageNamed:highlightImgName] forState:UIControlStateHighlighted];
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/**
 创建既有文字又有图片的button
 */
+ (instancetype)creatBtnWithFrame:(CGRect)frame title:(NSString *)title font:(CGFloat)font titleColor:(UIColor *)titleColor highlightColor:(UIColor *)highlightColor imgName:(NSString *)imgName highlightImgName:(NSString *)highlightImgName taret:(id)target action:(SEL)action {
    
    UIButton *button = [self creatBtnWithFrame:frame title:title font:font titleColor:titleColor highlightColor:highlightColor taret:target action:action];
    
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    if (highlightImgName) {
        [button setImage:[UIImage imageNamed:highlightImgName] forState:UIControlStateHighlighted];
    }
    return button;
}

- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space
{
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
        case MKButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case MKButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

@end
