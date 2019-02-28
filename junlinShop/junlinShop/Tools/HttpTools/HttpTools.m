//
//  HttpTools.m
//  SDAutoLayoutDemo
//
//  Created by 叶旺 on 16/1/15.
//  Copyright © 2016年 叶旺. All rights reserved.
//

#import "HttpTools.h"

@implementation HttpTools

/**
 *  get 请求
 */
+(void)Get1:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    if (!URLString) return;
    
    NSString *encodedString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager * manager = [self manager1];
    //    NSLog(@"URLString____%@",encodedString);
    
    [manager GET:encodedString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"responseObject____%@",responseObject);
        
//        if([[(NSDictionary *)responseObject allKeys] containsObject:@"code"]) {
//            if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
//
//                if (success) {
//                    success(responseObject);
//                }
//
//
//
//            }else { // result = 0时
//                // [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"ErrorMsg"]];
//                if (failure) {
//                    NSError *error = [NSError errorWithDomain:@"xxx" code:2 userInfo:responseObject];
//                    failure(error);
//                }
//            }
//        } else {
//            if (success) {
//                success(responseObject);
//            }
//        }
        
        // 请求成功
        if(responseObject){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (success) {
                success(dict);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
}

/**
 *  get 请求
 */
+(void)Get:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    if (!URLString) return;

    NSString *encodedString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    AFHTTPSessionManager * manager = [self manager];
//    NSLog(@"URLString____%@",encodedString);

    [manager GET:encodedString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"responseObject____%@",responseObject);

        if([[(NSDictionary *)responseObject allKeys] containsObject:@"code"]) {
            if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
                
                if (success) {
                    success(responseObject);
                }
                
            }else { // result = 0时
                // [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"ErrorMsg"]];
                if (failure) {
                    NSError *error = [NSError errorWithDomain:@"xxx" code:2 userInfo:responseObject];
                    failure(error);
                }
            }
        } else {
            if (success) {
                success(responseObject);
            }
        }
        
        
 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        if (failure) {
            failure(error);
        }
        
    }];
}


/**
 *  post 请求
 */
+(void)Post:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    if (!URLString) return;
   
    NSString *encodedString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager * manager = [self manager];

    [manager POST:encodedString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject____%@",responseObject);

        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
        
            if (success) {
                success(responseObject);
            }
            
        }else {
            
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"xxx" code:2 userInfo:responseObject];
                failure(error);
            }
            // result = 0时

            NSString *msg = [responseObject objectForKey:@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
           
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/**
 *  post 请求
 */
+(void)Post:(NSString *)URLString andBody:(NSString *)body success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    if (!URLString) return;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:URLString]];
    NSString *contentType = @"application/json";
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
         {
             if (error==nil)
             {
                 NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
                 if ([[resultDict objectForKey:@"code"] integerValue] == 200) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (success) {
                             success(resultDict);
                         }
                     });
                     
                 }else {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (failure) {
                             NSError *error = [NSError errorWithDomain:@"xxx" code:2 userInfo:resultDict];
                             failure(error);
                             
                             [SVProgressHUD showErrorWithStatus:[resultDict objectForKey:@"msg"]];
                         }
                     });
                     
                 }
             }else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (failure) {
                         failure(error);
                     }
                 });
             }
         }];
    [sessionDataTask resume];
    
}

/**
 *  put 请求
 */
+ (void)Put:(NSString *)URLString
 parameters:(id)parameters
    success:(void (^)(id))success
    failure:(void (^)(NSError *))failure {
    if (!URLString) return;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [parameters setValue:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"Version"];
    
    AFHTTPSessionManager * manager = [self manager];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject objectForKey:@"Result"] integerValue] == 1) {
            
            if (success) {
                success(responseObject);
            }
            
        } else if ([[responseObject objectForKey:@"Result"] integerValue] == 0) {
            
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"xxx" code:2 userInfo:responseObject];
                failure(error);
            }
            // result = 0时
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"ErrorMsg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 *  delete 请求
 */
+ (void)DELETE:(NSString *)URLString
    parameters:(id)parameters
       success:(void (^)(id))success
       failure:(void (^)(NSError *))failure {
    if (!URLString) return;
    
    //    if ([HttpManager sharedManager].networkStats == StatusNotReachable) {
    //        NSLog(@"没有网络");
    //        return;
    //    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [parameters setValue:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"Version"];
    
    AFHTTPSessionManager * manager = [self manager];
    
    [manager DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject objectForKey:@"Result"] integerValue] == 1) {
            
            if (success) {
                success(responseObject);
            }
            
        } else if ([[responseObject objectForKey:@"Result"] integerValue] == 0) {
            
            if (failure) {
                failure(responseObject);
            }
            // result = 0时
            [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"ErrorMsg"]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


/**
 *  上传图片
 */
+(void)UpLoadWithImage:(UIImage *)image url:(NSString *)urlString filename:(NSString *)filename name:(NSString *)name parameters:(id)parameters progress:(void (^)(int64_t, int64_t))progress success:(void (^)(id))success failure:(void (^)(NSError *))failure{
 /*   if ([HttpManager sharedManager].networkStats == StatusNotReachable) {
        NSLog(@"没有网络");
        return;
    }*/
    AFHTTPSessionManager * manager = [self manager];

    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //压缩图片
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"junlin-%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传图片成功=%@",responseObject);
        if ([[responseObject objectForKey:@"code"] integerValue] == 200) {
            if (success) {
                success(responseObject);
            }
        }
    
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传图片失败error=%@",error);
        
        if (failure) {
            failure(error);
        }
        
    }];
    
}


/**
 * 上传文件
 */
+(void)UpLoadFile:(NSString *)filePath url:(NSString *)urlString filename:(NSString *)filename name:(NSString *)name parameters:(id)parameters progress:(void (^)(int64_t, int64_t))progress success:(void (^)(id))success failure:(void (^)(NSError *))failure{

    AFHTTPSessionManager * manager = [self manager];
    
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        // 上传文件
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:name fileName:filename mimeType:@"application/octet-stream" error:nil];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传图片成功=%@",responseObject);
        
        if (success) {
            success(responseObject);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传图片失败error=%@",error);
        
        if (failure) {
            failure(error);
        }
        
    }];

}


/**
 *  下载
 */
+(void)DownLoad:(NSString *)urlString progress:(void (^)(int64_t, int64_t))progress success:(void (^)(id))success failure:(void (^)(NSError *))failure{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURL *url = [NSURL URLWithString:urlString];
    //创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下下载进度
        NSLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
        progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //下载地址
        NSLog(@"默认下载地址:%@",targetPath);
        
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL URLWithString:filePath];
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //下载完成调用的方法
        NSLog(@"下载完成：");
        NSLog(@"%@--%@",response,filePath);
        if (error == nil) {
            //返回完整路径
            if (success) {
                success([filePath path]);
            }
            
        } else {
            
            if (failure) {
                failure(error);
            }
        
        }

        
    }];
    
    //开始启动任务
    [task resume];

}

+(AFHTTPSessionManager*)manager{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSSet *acceptableContentTypes = [NSSet setWithObjects:
                                                         @"application/json",
                                                         @"text/html",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/plain",
                                                         @"text/xml",
                                                         @"image/*",nil];
    manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    manager.requestSerializer.timeoutInterval=30;
     return manager;

}

+(AFHTTPSessionManager*)manager1{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSSet *acceptableContentTypes = [NSSet setWithObjects:
                                     @"application/json",
                                     @"text/html",
                                     @"text/json",
                                     @"text/javascript",
                                     @"text/plain",
                                     @"text/xml",
                                     @"image/*",nil];
    manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    manager.requestSerializer.timeoutInterval=30;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
    
}

@end
