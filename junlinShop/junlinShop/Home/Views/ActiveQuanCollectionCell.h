//
//  ActiveQuanCollectionCell.h
//  junlinShop
//
//  Created by 叶旺 on 2018/3/25.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveQuanCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *getBtn;

- (void)setDataWithDic:(NSDictionary *)dic;

@end
