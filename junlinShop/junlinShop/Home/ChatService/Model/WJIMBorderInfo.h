//
//  WJIMBorderInfo.h
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**聊天的边框    -- //就是内容的frame计算*/

@interface WJIMBorderInfo : NSObject

@property (nonatomic,assign)CGFloat leftPadding; //左边
@property (nonatomic,assign)CGFloat rightPadding; //右边
@property (nonatomic,assign)CGFloat topPadding;  //顶部
@property (nonatomic,assign)CGFloat bottomPadding;//底部

@property (nonatomic,strong)UIImage *borderImage;//边框图片

+ (WJIMBorderInfo *)defaultBorderInfoFromOther;
+ (WJIMBorderInfo *)defaultBorderInfoFromMe;
@end
