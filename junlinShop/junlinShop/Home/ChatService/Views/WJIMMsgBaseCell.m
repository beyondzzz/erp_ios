//
//  WJIMMsgBaseCell.m
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJIMMsgBaseCell.h"
#import "WJBorderManager.h"

@implementation WJIMMsgBaseCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self defaultCommon];
        
        self.avatarView = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.headerView = [[UIView alloc]initWithFrame:CGRectZero];
        self.footerView= [[UIView alloc]initWithFrame:CGRectZero];
        self.timeLabel = [[MoyouSmallIconText alloc]initWithFrame:CGRectMake(0, 0, 60, 20)];
        self.bodyBgView = [[UIButton alloc]initWithFrame:CGRectZero];
    
        self.timeLabel.leftPadding = 0;
        self.timeLabel.rightPadding = 0;
        self.timeLabel.iconTextPadding = 0;
        self.timeLabel.edge = UIEdgeInsetsMake(2, 2, 2, 2);
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.bodyBgView];
        [self.contentView addSubview:self.footerView];
        [self.contentView addSubview:self.headerView];
        [self.footerView addSubview:self.timeLabel];
        
        self.timeLabel.font = 12;
        [self.timeLabel setRightImage:[UIImage imageNamed:@"chat_ipunt_message"] text:@"啊哈哈"];
        [self.avatarView setBorder:kBackGreenColor width:1 radius:WJCHAT_CELL_AVATARWIDTH / 2];
        
        //没有添加header
        self.headerView.layer.borderWidth = 1;
//        self.timeLabel.layer.borderWidth = 1;
//        self.bodyBgView.layer.borderWidth = 1;
        
    }
    return self;
}

- (void)defaultCommon {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.detailTextLabel.hidden = YES;
    self.textLabel.hidden = YES;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
}

#pragma mark - FrameLayou

- (void)avatarFrameLayout {
    //    CGFloat minY = self.cellHeight-WJCHAT_CELL_AVATARWIDTH-WJCHAT_CELL_TIMELABELHEIGHT;
    CGFloat minY = 24;
    if (_msg.fromType == IMMsgFromOther) {
        self.avatarView.frame = CGRectMake(2, minY, WJCHAT_CELL_AVATARWIDTH, WJCHAT_CELL_AVATARWIDTH);
    }else {
        self.avatarView.frame = CGRectMake(WJCHAT_CELL_WIDTH-WJCHAT_CELL_AVATARWIDTH - 2, minY, WJCHAT_CELL_AVATARWIDTH, WJCHAT_CELL_AVATARWIDTH);
    }
}

- (void)timeLabelFrameLayout {
    if (_msg.fromType == IMMsgFromOther) {
        self.footerView.frame = CGRectMake(self.bodyBgView.left, self.cellHeight-WJCHAT_CELL_TIMELABELHEIGHT, WJCHAT_CELL_CONTENT_MAXWIDTH, WJCHAT_CELL_TIMELABELHEIGHT);
    }else {
        self.footerView.frame = CGRectMake(self.bodyBgView.left, self.cellHeight-WJCHAT_CELL_TIMELABELHEIGHT, WJCHAT_CELL_CONTENT_MAXWIDTH, WJCHAT_CELL_TIMELABELHEIGHT);
    }
    self.timeLabel.frame = CGRectMake(self.bodyBgView.width - 60, 0, 60, 20);
    [self.timeLabel setRightImage:[UIImage imageNamed:@"chat_ipunt_message"] text:@"12:00"];
}

- (void)baseFrameLayout {
    [self avatarFrameLayout];
    [self timeLabelFrameLayout];
}

#pragma mark - private


#pragma mark - public

- (void)setIMMsg:(IMMsg *)msg {
    _msg = msg;
}

- (WJBorderManager *)borderImageAndFrame {
    WJBorderManager *manager = [[WJBorderManager alloc]initWithMsg:_msg];
    [self.bodyBgView setBackgroundImage:manager.borderImage forState:UIControlStateNormal];
    if (_msg.fromType == IMMsgFromOther) {
        self.bodyBgView.frame = CGRectMake(WJCHAT_CELL_LEFT_PADDING, WJCHAT_CELL_HEADER, manager.width, manager.height);
    }else {
        self.bodyBgView.frame = CGRectMake(WJCHAT_CELL_WIDTH-WJCHAT_CELL_RIGHT_PADDING-manager.width, WJCHAT_CELL_HEADER, manager.width, manager.height);
    }
    return manager;
}

+ (CGFloat)heightForCellWithMsg:(IMMsg *)msg {
    return 44;
}

+ (CGFloat)cellHeight {
    return cellHeight+0.001;
}

- (IMMsg *)msg {
    return _msg;
}

@end
