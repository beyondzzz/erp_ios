//
//  CircleImageView.h
//  mhd2
//
//  Created by peter.ye on 16/9/24.
//  Copyright © 2016年 peter.ye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *countLab;

- (void)setImageArray:(NSArray *)imageArr andIndex:(NSInteger)index;

- (void)setImageArray:(NSArray *)imageArr andIndex:(NSInteger)index descuribtionArray:(NSArray *)desArr;

@end
