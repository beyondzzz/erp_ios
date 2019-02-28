//
//  UIImage+YWExtension.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YWExtension)

+ (UIImage *)createImageWithSize:(CGSize)size andColor:(UIColor *)color;

/** 图片缩放 */
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

/** 图片模糊方法 */
+ (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;

/** 模糊图片方法 */
+ (UIImage *)coreBlurImage:(UIImage *)image
            withBlurNumber:(CGFloat)blur;

@end
