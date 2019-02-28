//
//  CacheManager.m
//  junlinShop
//
//  Created by apple on 2018/8/16.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "CacheManager.h"

@implementation CacheManager
+ (instancetype)share{
    static CacheManager *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[self alloc] init];
    });
    return cache;
}



- (instancetype)init{
    self = [super init];
    if (self) {
 
    }
    return self;
}

- (YYCache *)commonCache{
    if (!_commonCache) {
        _commonCache = [YYCache cacheWithName:@"CommonCache"];
    }
    return _commonCache;
}


// 显示缓存大小
+(CGFloat)filePath
{
    
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    return [self folderSizeAtPath :cachPath];
    
}
//1:首先我们计算一下 单个文件的大小

+ (long long)fileSizeAtPath:(NSString *)filePath{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error: nil ] fileSize];
    }
    
    return 0 ;
    
}
//2:遍历文件夹获得文件夹大小，返回多少 M（提示：你可以在工程界设置（)m）

+ (CGFloat)folderSizeAtPath:(NSString *)folderPath{
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    long long folderSize = 0;
    if (![manager fileExistsAtPath:folderPath]) return folderSize;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath :folderPath] objectEnumerator ];
    
    NSString * fileName;
    
    while ((fileName = [childFilesEnumerator nextObject ]) != nil ){
        
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        
    }
    
    folderSize += [[SDImageCache sharedImageCache] getSize];
    
    return folderSize / ( 1024.0 * 1024.0 );
    
}




// 清理缓存

+ (void)clearFile
{
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    
    NSLog (@"cachpath = %@", cachPath);
    
    for (NSString *p in files) {
        
        NSError *error = nil ;
        
        NSString *path = [cachPath stringByAppendingPathComponent:p];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:path error :&error];
            
        }
        
    }
    
    [[SDImageCache sharedImageCache] clearMemory];
    
}

@end
