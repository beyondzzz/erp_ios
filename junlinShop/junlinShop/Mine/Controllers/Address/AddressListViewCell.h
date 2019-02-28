//
//  AddressListViewCell.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressModel.h"

@interface AddressListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *phoneLab;
@property (weak, nonatomic) IBOutlet UILabel *addressLab;
@property (weak, nonatomic) IBOutlet UIButton *morenBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

- (void)setDataWithModel:(AddressModel *)model completeBlock:(void (^)(AddressModel *finishModel, NSInteger btnTag))completeBlock;

@end
