//
//  UIImage+Compress.m
//  OCKJ
//
//  Created by wangjun on 15/11/3.
//  Copyright © 2015年 Ashermed. All rights reserved.
//

#define MAX_IMAGEPIX_WIDTH 800.0      // max pix 200.0px
#define MAX_IMAGEPIX_HEIGHT 600.0    // max pix 200.0px
#define MAX_IMAGEDATA_LEN 50000.0   // max data length 5K

#import "UIImage+Compress.h"

@implementation UIImage (Compress)

- (UIImage *)compressedImage
{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    if (width <= MAX_IMAGEPIX_WIDTH && height <= MAX_IMAGEPIX_HEIGHT) {
        
        return self;
    }
    
    if (width == 0 || height == 0) {
        
        return self;
    }
    
    UIImage *newImage = nil;
    CGFloat widthFactor = MAX_IMAGEPIX_WIDTH / width;
    CGFloat heightFactor = MAX_IMAGEPIX_HEIGHT / height;
    CGFloat scaleFactor = 0.0;
    
    if (widthFactor > heightFactor)
        scaleFactor = heightFactor; // scale to fit height
    else
        scaleFactor = widthFactor; // scale to fit width
    
    CGFloat scaledWidth  = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSData *)compressedData:(CGFloat)compressionQuality
{
    assert(compressionQuality <= 1.0 && compressionQuality >= 0);
    
    return UIImageJPEGRepresentation(self, compressionQuality);
}

- (CGFloat)compressionQuality
{
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    NSUInteger dataLength = [data length];
    
    if(dataLength > MAX_IMAGEDATA_LEN) {
        
        return 1.0 - MAX_IMAGEDATA_LEN / dataLength;
        
    } else {
        
        return 1.0;
    }
}

- (NSData *)compressedData
{
    CGFloat quality = [self compressionQuality];
    return [self compressedData:quality];
}

- (NSData *)compressedDataWithPercent4
{
    CGFloat quality = 1.0;
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    NSUInteger dataLength = [data length];
    
    if(dataLength > MAX_IMAGEDATA_LEN) {
        quality = 0.5;
    }
    return [self compressedData:quality];
}

@end
