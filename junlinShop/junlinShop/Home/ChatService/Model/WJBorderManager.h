//
//  WJBorderManager.h
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "IMMsg.h"
#import "WJIMMsgBaseCell.h"

@interface WJBorderManager : NSObject

@property (nonatomic,assign)CGFloat leftPadding; //左边
@property (nonatomic,assign)CGFloat rightPadding; //右边
@property (nonatomic,assign)CGFloat topPadding;  //顶部
@property (nonatomic,assign)CGFloat bottomPadding;//底部

@property (nonatomic,assign)CGFloat labelWidth;//label宽度
@property (nonatomic,assign)CGFloat labelHeight;//label高度

@property (nonatomic,assign)CGFloat width;//宽度
@property (nonatomic,assign)CGFloat height;//高度

@property (nonatomic,strong)UIImage *borderImage;//边框图片

- (instancetype)initWithMsg:(IMMsg *)msg;


@end
