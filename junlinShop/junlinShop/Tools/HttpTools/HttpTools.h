//
//  HttpTools.h
//  SDAutoLayoutDemo
//
//  Created by 叶旺 on 16/1/15.
//  Copyright © 2016年 叶旺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface HttpTools : NSObject
+(void)Get1:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure;

+ (void)Get:(NSString*)URLString
 parameters:(id)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure;


+ (void)Post:(NSString*)URLString
  parameters:(id)parameters
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

+ (void)Post:(NSString*)URLString andBody:(NSString *)body
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

+ (void)Put:(NSString *)URLString
    parameters:(id)parameters
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *))failure;

+ (void)DELETE:(NSString *)URLString
 parameters:(id)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *))failure;

+ (void)DownLoad:(NSString*)urlString
        progress:(void(^)(int64_t bytesProgress,int64_t totalBytesProgress))progress
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSError *error))failure;



/**
 *  上传图片
 *  @param image      上传的图片
 *  @param urlString        请求连接，根路径
 *  @param filename   图片的名称(如果不传则以当时间命名)
 *  @param name       上传图片时填写的图片对应的参数（一般file）
 *  @param parameters     参数
 *  @param progress   上传进度
 *  @param success    请求成功返回数据
 *  @param failure       请求失败
 */
+ (void)UpLoadWithImage:(UIImage*)image
           url:(NSString*)urlString
      filename:(NSString *)filename
          name:(NSString *)name
    parameters:(id)parameters
      progress:(void(^)(int64_t bytesProgress,int64_t totalBytesProgress))progress
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;



/**
 *  上传文件
 *  @param filePath   文件地址
 */
+ (void)UpLoadFile:(NSString*)filePath
           url:(NSString*)urlString
      filename:(NSString *)filename
          name:(NSString *)name
    parameters:(id)parameters
      progress:(void(^)(int64_t bytesProgress,int64_t totalBytesProgress))progress
       success:(void (^)(id responseObject))success
       failure:(void (^)(NSError *error))failure;

@end
