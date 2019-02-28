//
//  NoticeCenterTableCell.h
//  junlinShop
//
//  Created by 叶旺 on 2018/3/18.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeCenterTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UIImageView *noticeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *noticeLab;

@end
