//
//  UIView+ALWAdd.h
//  ASHBgxnsq
//
//  Created by 李西亚 on 16/6/3.
//  Copyright © 2016年 wangjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ALWAdd)
@property (nonatomic,assign) CGFloat radius;

/**
 *  添加边框:四边 颜色 圆角半径
 */
-(void)setBorder:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius;


/**
 *  自动从xib创建视图
 */
+(instancetype)viewFromXIB;


/**
 * 判断一个控件是否真正显示在主窗口
 */
- (BOOL)isShowingOnKeyWindow;



/**
 *  添加点点击手势
 */
- (void)addTapGesturesTarget:(id)target selector:(SEL)selector;


@end
