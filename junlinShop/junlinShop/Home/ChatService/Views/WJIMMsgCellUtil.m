//
//  WJIMMsgCellUtil.m
//  moyouAPP
//
//  Created by 幻想无极（谭启宏） on 16/8/17.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJIMMsgCellUtil.h"

@implementation WJIMMsgCellUtil

+ (CGFloat)cellHeightForMsg:(id)msg {
    if ([msg isKindOfClass:[IMMsg class]]) {
        IMMsg *tmpMsg = (IMMsg *)msg;
        if (tmpMsg.msgType == IMMsgTypeText) {
            return [WJIMTextMsgCell cellHeight];
        } else if (tmpMsg.msgType == IMMsgTypePic) {
            return [WJIMPicMsgCell cellHeight];
        } else if (tmpMsg.msgType == IMMsgTypeEmotion) {
            return [WJIMEmotionCell cellHeight];
        }
        else {
            return 38.0f;
        }
    }
    return 38.0f;
}

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForMsg:(id)msg {
    if ([msg isKindOfClass:[IMMsg class]]) {
        WJIMMsgBaseCell *cell = nil;
        IMMsg *tmpMsg = (IMMsg *)msg;
        
        //文字cell
        if (tmpMsg.msgType == IMMsgTypeText) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"IMTextMsg"];
            if(cell == nil){
                cell = [[WJIMTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMTextMsg"];
            }
            [cell setIMMsg:msg];
            
        }
        //图片cell
        else if (tmpMsg.msgType == IMMsgTypePic) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"IMPicMsg"];
            if(cell == nil){
                cell = [[WJIMPicMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMPicMsg"];
            }
            [cell setIMMsg:msg];
        }
        //表情
        else if (tmpMsg.msgType == IMMsgTypeEmotion) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"IMEmotionMsg"];
            if(cell == nil){
                cell = [[WJIMEmotionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IMEmotionMsg"];
            }
            [cell setIMMsg:msg];
        }
        //基本的cell
        else {
            cell = [[WJIMMsgBaseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basecell"];
        }
        return cell;
    }

    else {
        return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    }
}

@end
