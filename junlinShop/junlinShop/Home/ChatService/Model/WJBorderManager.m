//
//  WJBorderManager.m
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJBorderManager.h"
#import "WJIMBorderInfo.h"

@interface WJBorderManager ()

@property (nonatomic,strong)WJIMBorderInfo *info;
@property (nonatomic,strong)IMMsg *msg;

@end

@implementation WJBorderManager


- (instancetype)initWithMsg:(IMMsg *)msg {
    self = [super init];
    if (self) {
        self.msg = msg;
        //计算frame方法
        CGRect rect= [msg.msgBody boundingRectWithSize:CGSizeMake(WJCHAT_CELL_CONTENT_MAXWIDTH-20, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
        self.labelWidth = rect.size.width;
        self.labelHeight = rect.size.height;
       
        if (self.labelHeight < 25) {
            self.labelHeight = 30;
        }
        
        if (msg.fromType == IMMsgFromOther) {
           self.info = [WJIMBorderInfo defaultBorderInfoFromOther];
            
        }else {
            self.info = [WJIMBorderInfo defaultBorderInfoFromMe];
        }
       
        switch (msg.msgType) {
            case IMMsgTypeText:
                [self msgText];
                break;
                
            case IMMsgTypeAudio:
                [self msgAudio];
                break;
                
            case IMMsgTypePic:
            case IMMsgTypeVideo:
                [self picMsgAndVideoMsg];
                break;
            case IMMsgTypeEmotion:
                [self msgEmotion];
                break;
            default:
                break;
        }
    }
    return self;
}

#pragma mark - 根据不同的类型选择

- (void)msgText {
    self.width = self.labelWidth + self.info.leftPadding + self.info.rightPadding;
    self.height = self.labelHeight + self.info.bottomPadding;
    
    self.leftPadding = self.info.leftPadding;
    if (self.labelHeight == 30) {
        self.topPadding = 5;
    }else {
        self.topPadding = 10;
    }
}

- (void)msgAudio {
    CGFloat testf = 20;
    
   CGFloat width = WJCHAT_CELL_CONTENT_MAXWIDTH * testf / 60;//秒速
    if (width < 200) {
        width = 200;
    }else if (width > WJCHAT_CELL_CONTENT_MAXWIDTH) {
        width = WJCHAT_CELL_CONTENT_MAXWIDTH;
    }
    self.width = width;
    self.height = 44;
    if (self.msg.fromType == IMMsgFromOther) {
        self.leftPadding = 15;
        self.rightPadding = 5;
    }else {
        self.rightPadding = 15;
        self.leftPadding = 5;
    }
}

- (void)picMsgAndVideoMsg {
    
    UIImage *image = [UIImage imageNamed:@"meitu_boy"];
    
    CGFloat f = image.size.height/image.size.width;
    
    CGFloat width = image.size.width;
    if (image.size.width/WJCHAT_CELL_CONTENT_MAXWIDTH > 0) {
        width = WJCHAT_CELL_CONTENT_MAXWIDTH;
    }else {
        width = image.size.width;
    }
    
    CGFloat height = width * f;
    
    self.width = width;
    self.height = height;
}

- (void)msgEmotion {
    self.width = 120;
    self.height = 120;
}

- (UIImage *)borderImage {
    return self.info.borderImage;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImage *normal;
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
        self.leftPadding = 10;
        self.rightPadding = 10;
        self.topPadding = 1;
        self.bottomPadding = 1;
    }
    return self;
}


@end
