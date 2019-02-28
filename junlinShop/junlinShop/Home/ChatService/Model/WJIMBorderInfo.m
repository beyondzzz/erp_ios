//
//  WJIMBorderInfo.m
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJIMBorderInfo.h"

@implementation WJIMBorderInfo

//左边的边框
+ (WJIMBorderInfo *)defaultBorderInfoFromOther {
    
    UIImage *normal;
    //bubble_stroked
    //chatfrom_bg_normal
    normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
    normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    
    
    
    
//    normal = [UIImage imageNamed:@"bubble_stroked"];
//    normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    
    WJIMBorderInfo *info = [[WJIMBorderInfo alloc]init];
    info.leftPadding = 22;
    info.rightPadding = 10;
    info.topPadding = 35;
    info.bottomPadding = 10;
    info.borderImage = normal;
    return info;
}

//右边的边框
+ (WJIMBorderInfo *)defaultBorderInfoFromMe {
    UIImage *normal;
    //bubble_regular
    //chatto_bg_normal
    //bubble_regular
    normal = [UIImage imageNamed:@"chatto_bg_normal"];
    normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
    
//    normal = [UIImage imageNamed:@"bubble_stroked"];
//    normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 20) resizingMode:UIImageResizingModeStretch];
    
    WJIMBorderInfo *info = [[WJIMBorderInfo alloc]init];
    info.leftPadding = 10;
    info.rightPadding = 20;
    info.topPadding = 35;
    info.bottomPadding = 22;
    info.borderImage = normal;
    return info;
}

@end
