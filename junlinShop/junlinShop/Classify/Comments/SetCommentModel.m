//
//  SetCommentModel.m
//  junlinShop
//
//  Created by jianxuan on 2018/1/29.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "SetCommentModel.h"

@implementation SetCommentModel

- (NSMutableArray *)imageArr {
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

- (NSMutableArray *)imageUrlArr {
    if (!_imageUrlArr) {
        _imageUrlArr = [NSMutableArray arrayWithObjects:@"0", @"0", @"0", @"0", @"0", nil];
    }
    return _imageUrlArr;
}

@end
