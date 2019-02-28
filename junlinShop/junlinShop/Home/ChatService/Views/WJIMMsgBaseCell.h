//
//  WJIMMsgBaseCell.h
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IMMsg.h"
#import "UIView+IM.h"
#import "MoyouSmallIconText.h"
//#import "WJBorderManager.h"
@class WJBorderManager;
#define WJCHAT_CELL_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds) //cell宽度
#define WJCHAT_CELL_AVATARWIDTH 44 //头像宽度
#define WJCHAT_CELL_LEFT_PADDING 50 //左边距离
#define WJCHAT_CELL_RIGHT_PADDING 50
#define WJCHAT_CELL_HEADER 20          //header高度
#define WJCHAT_CELL_TIMELABELHEIGHT 30 //footer高度
#define WJCHAT_CELL_CONTENT_MAXWIDTH (WJCHAT_CELL_WIDTH - WJCHAT_CELL_LEFT_PADDING-WJCHAT_CELL_RIGHT_PADDING)//文本最大宽度


static CGFloat cellHeight = 0;//计算cell的高度，静态变量

/**基础cell*/
@interface WJIMMsgBaseCell : UITableViewCell {
    IMMsg *_msg;//消息
}

@property (nonatomic,strong)UIImageView *avatarView; //头像
@property (nonatomic,strong)UIView *footerView;      //底部
@property (nonatomic,strong)UIView *headerView;      //底部
@property (nonatomic,strong)MoyouSmallIconText *timeLabel;//时间
@property (nonatomic,strong)UIButton *bodyBgView;    //文本区域
@property (nonatomic,assign)CGFloat cellHeight;//高度属性
//添加消息
- (void)setIMMsg:(IMMsg *)msg;
- (WJBorderManager *)borderImageAndFrame;
- (void)avatarFrameLayout;
- (void)timeLabelFrameLayout;
- (void)baseFrameLayout;
//cell的高度
+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg;

- (IMMsg *)msg;
+ (CGFloat)cellHeight;
@end
