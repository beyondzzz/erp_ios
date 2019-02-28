//
//  CacheManager.h
//  junlinShop
//
//  Created by apple on 2018/8/16.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache.h>

@interface CacheManager : NSObject
@property (nonatomic, strong) YYCache *commonCache;


+ (instancetype)share;


+ (CGFloat)folderSizeAtPath:(NSString *)folderPath;
+ (void)clearFile;


@end
