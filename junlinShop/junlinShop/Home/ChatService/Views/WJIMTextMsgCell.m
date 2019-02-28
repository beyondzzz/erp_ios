//
//  WJIMTextMsgCell.m
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJIMTextMsgCell.h"
#import "WJBorderManager.h"

@implementation WJIMTextMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _textView = [[UILabel alloc]initWithFrame:CGRectZero];
        _textView.font = WJIMTextMsgCellTextFont;
        _textView.numberOfLines = 0;
        [self.bodyBgView addSubview:_textView];
    
    }
    return self;
}

- (void)setIMMsg:(IMMsg *)msg {
    _msg = msg;
    _textView.text = _msg.msgBody;

    WJBorderManager *manager =  [self borderImageAndFrame];
    
    _textView.frame = CGRectMake(manager.leftPadding, manager.topPadding,  manager.labelWidth,  manager.labelHeight);
    
    cellHeight = self.bodyBgView.bottom+WJCHAT_CELL_TIMELABELHEIGHT;
    self.cellHeight = cellHeight;
    
    [self baseFrameLayout];
}

+ (CGFloat)cellHeight {
    return cellHeight+0.001;
}

@end
