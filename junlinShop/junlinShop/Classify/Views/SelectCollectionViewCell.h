//
//  SelectCollectionViewCell.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/25.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brandLeftConstraint;

- (void)setBrandStr:(NSString *)brandStr isSelected:(BOOL)isSelected;

@end
