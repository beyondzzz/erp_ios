//
//  XBSettingItemModel.m
//  xiu8iOS
//
//  Created by XB on 15/9/18.
//  Copyright (c) 2015年 xiu8. All rights reserved.
//

#import "XBSettingItemModel.h"

@implementation XBSettingItemModel

- (CGFloat)rowHeight {
    if (!_rowHeight) {
        _rowHeight = 44;
    }
    return _rowHeight;
}

@end
