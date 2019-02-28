//
//  WJIMPicMsgCell.m
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/6.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "WJIMPicMsgCell.h"
#import "WJBorderManager.h"

@interface WJIMPicMsgCell ()

@end

@implementation WJIMPicMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.picImage = [UIImageView new];
        self.picImage.backgroundColor = [UIColor redColor];
        [self.bodyBgView addSubview:self.picImage];
    }
    return self;
}


- (void)setIMMsg:(IMMsg *)msg {
    _msg = msg;
    [self borderImageAndFrame];

    self.picImage.image = [UIImage imageNamed:@"meitu_boy"];
    if (msg.fromType == IMMsgFromOther) {
       
        self.picImage.frame = CGRectMake(20,10,self.bodyBgView.width-30,self.bodyBgView.height-20);
    }else {
 
        self.picImage.frame = CGRectMake(10,10,self.bodyBgView.width-25,self.bodyBgView.height-20);
    }
    
    cellHeight =  self.bodyBgView.bottom+WJCHAT_CELL_TIMELABELHEIGHT;
    self.cellHeight = cellHeight;
    [self baseFrameLayout];
}

+ (CGFloat)cellHeight {
    return cellHeight+0.001;
}

@end
