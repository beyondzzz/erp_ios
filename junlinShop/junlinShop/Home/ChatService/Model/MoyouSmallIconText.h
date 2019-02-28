//
//  MoyouSmallIconText.h
//  moyouAPP
//
//  Created by 幻想无极（谭启宏） on 16/8/19.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoyouSmallIconText : UIControl

//----xib设置
@property (nonatomic,assign)CGFloat maxWith;
@property (nonatomic,assign)CGFloat maxHeight;

//设置属性
@property (nonatomic,assign)UIEdgeInsets edge;      //图片边距
@property (nonatomic,assign)CGFloat iconTextPadding;//文字图片中间间隔
@property (nonatomic,assign)CGFloat leftPadding;    //左边间隔
@property (nonatomic,assign)CGFloat rightPadding;   //右边间隔

@property (nonatomic,assign)CGFloat font;           //字体大小
@property (nonatomic,strong)UIColor *color;         //文字颜色

//设置图片和文字
- (void)setleftImage:(UIImage *)image text:(NSString *)text;
- (void)setRightImage:(UIImage *)image text:(NSString *)text;



@end
