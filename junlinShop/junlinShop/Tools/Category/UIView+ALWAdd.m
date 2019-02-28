//
//  UIView+ALWAdd.m
//  ASHBgxnsq
//
//  Created by 李西亚 on 16/6/3.
//  Copyright © 2016年 wangjun. All rights reserved.
//

#import "UIView+ALWAdd.h"

@implementation UIView (ALWAdd)

#pragma mark  圆角处理
-(void)setRadius:(CGFloat)r{
    
    if(r<=0) r=self.frame.size.width * .5f;
    
    //圆角半径
    self.layer.cornerRadius=r;
    
    //强制
    self.layer.masksToBounds=YES;
}

-(CGFloat)radius{
    return 0;
}


/**
 *  添加边框
 */
-(void)setBorder:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius{
    CALayer *layer = self.layer;
    [layer setMasksToBounds:YES];
    
    [layer setCornerRadius:radius];//设置矩形四个圆角半
    layer.borderColor = color.CGColor;
    layer.borderWidth = width;
}

/**
 *  自动从xib创建视图
 */
+(instancetype)viewFromXIB{
    
    NSString *name=NSStringFromClass(self);
    
    UIView *xibView=[[[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil] firstObject];
    
    if(xibView==nil){
        NSLog(@"从xib创建视图失败，当前类是：%@",name);
    }
    
    return xibView;
}


/**
 * 判断一个控件是否真正显示在主窗口
 */
- (BOOL)isShowingOnKeyWindow
{
    // 主窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    // 以主窗口左上角为坐标原点, 计算self的矩形框
    CGRect newFrame = [keyWindow convertRect:self.frame fromView:self.superview];
    CGRect winBounds = keyWindow.bounds;
    
    // 主窗口的bounds 和 self的矩形框 是否有重叠
    BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
    
    return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && intersects;
}

/**
 *  添加点点击手势
 */
- (void)addTapGesturesTarget:(id)target selector:(SEL)selector
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
}


@end
