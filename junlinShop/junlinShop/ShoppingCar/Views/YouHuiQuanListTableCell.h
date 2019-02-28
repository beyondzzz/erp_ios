//
//  YouHuiQuanListTableCell.h
//  junlinShop
//
//  Created by jianxuan on 2018/2/5.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouHuiQuanListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *specLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *specLabCenterConstraint;
@property (weak, nonatomic) IBOutlet UIButton *getBtn;


- (void)setDataWithDic:(NSDictionary *)dict;
- (void)setCanGetYouHuiQuanDataWithDic:(NSDictionary *)dict;

@end
