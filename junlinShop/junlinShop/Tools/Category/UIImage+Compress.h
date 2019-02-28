//
//  UIImage+Compress.h
//  OCKJ
//
//  Created by wangjun on 15/11/3.
//  Copyright © 2015年 Ashermed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

- (UIImage *)compressedImage;

- (CGFloat)compressionQuality;

- (NSData *)compressedData;

- (NSData *)compressedData:(CGFloat)compressionQuality;

- (NSData *)compressedDataWithPercent4;

@end
