//
//  WJIMMsgCellUtil.h
//  moyouAPP
//
//  Created by 幻想无极（谭启宏） on 16/8/17.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WJIMMsgBaseCell.h"
#import "WJIMTextMsgCell.h"
#import "WJIMPicMsgCell.h"
#import "WJIMEmotionCell.h"

@interface WJIMMsgCellUtil : NSObject

+ (CGFloat)cellHeightForMsg:(id)msg;

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForMsg:(id)msg;

@end
