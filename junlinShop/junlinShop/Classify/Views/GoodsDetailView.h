//
//  GoodsDetailView.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/15.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailView : UIView

@property (weak, nonatomic) IBOutlet UIView *imageBackView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *introdutionLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *saleCountLab;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLab;


@end
