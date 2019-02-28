//
//  WJIMTextMsgCell.h
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJIMMsgBaseCell.h"

#define WJIMTextMsgCellTextFont [UIFont systemFontOfSize:14] //文字的大小


/**文本cell*/
@interface WJIMTextMsgCell : WJIMMsgBaseCell
{
    UILabel *_textView;
}

+ (CGFloat)cellHeight;

@end
