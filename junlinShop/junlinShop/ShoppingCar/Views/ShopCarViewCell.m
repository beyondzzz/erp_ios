//
//  ShopCarViewCell.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "ShopCarViewCell.h"
#import "SkuSelectView.h"
#import "ActiveSelectView.h"

@implementation ShopCarViewCell

- (void)setDataWithModel:(ShopCarModel *)model completeBlock:(void (^)(BOOL))completeBlock {
    
    _goodsDetailLab.text = [model.dataDic objectForKey:@"goodsName"];
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:kAppendUrl(model.goodsImageUrl)] placeholderImage:kDefaultImage];
    if (model.skuSelectedDic) {
         _specLab.text = [model.skuSelectedDic objectForKey:@"specifications"];
          CGFloat price = [[model.skuSelectedDic objectForKey:@"price"] floatValue];
         _priceLab.text = [NSString stringWithFormat:@"¥ %.2f", price];
    } else {
        _specLab.text = model.specStr;
        CGFloat price = [model.price floatValue];
        
        _priceLab.text = [NSString stringWithFormat:@"¥ %.2f", price];
    }
    
    YWWeakSelf;
    NSArray *activeArr = [model.skuSelectedDic objectForKey:@"goodsActivitys"];
    if (model.isYuShou) {
        activeArr = [[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"goodsActivitys"];
    }
    if (activeArr.count) {
        _backViewTopConstraint.constant = 30;
        _activeBackView.hidden = NO;
        NSDictionary *activeDic = [activeArr.firstObject objectForKey:@"activityInformation"];
        
        switch ([[activeDic objectForKey:@"activityType"] intValue]) {
            case 0:
                _activeTagLab.text = @"折扣";
                _activeDetailLab.text = [NSString stringWithFormat:@"打%.1f折,最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue] * 10, [activeDic objectForKey:@"maxNum"]];
                break;
            case 1:
                _activeTagLab.text = @"团购";
                _activeDetailLab.text = [NSString stringWithFormat:@"团购单价为%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
                break;
            case 2:
                _activeTagLab.text = @"秒杀";
                _activeDetailLab.text = [NSString stringWithFormat:@"秒杀单价为%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
                break;
            case 3:
                _activeTagLab.text = @"立减";
                _activeDetailLab.text = [NSString stringWithFormat:@"该商品立减%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
                break;
            case 4:
                _activeTagLab.text = @"满减";
                _activeDetailLab.text = [NSString stringWithFormat:@"该商品满%.2f元，可减%.2f元", [[activeDic objectForKey:@"price"] floatValue], [[activeDic objectForKey:@"discount"] floatValue]];
                break;
            case 5:
                _activeTagLab.text = @"预售";
                _activeDetailLab.text = [NSString stringWithFormat:@"已参与预售活动：%@", [activeDic objectForKey:@"name"]];
                break;
            default:
                break;
        }
        
        if (activeArr.count > 1) {
            _activeBtn.hidden = NO;
        } else {
            _activeBtn.hidden = YES;
        }
        
        [[[_activeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [ActiveSelectView initWithActiveArray:activeArr isShow:YES];
        }];
        
    } else {
        _backViewTopConstraint.constant = 5;
        _activeBackView.hidden = YES;
    }
    
    [_AmountTextField setBorder:kGrayLineColor width:1.f radius:5.f];
    _AmountTextField.buyMinNumber = 1;
    _AmountTextField.TQTextFiled.text = [NSString stringWithFormat:@"%ld", model.selectNumber];
    _AmountTextField.stepLength = 1;
    
    _AmountTextField.changeNumber = ^(NSInteger number) {
        
        if (number == 0) {
            return ;
        }
        
        NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:userID forKey:@"userId"];
        [dict setValue:@"2" forKey:@"operation"];
        [dict setValue:[model.skuSelectedDic objectForKey:@"id"] forKey:@"goodsSpecificationDetailsId"];
        [dict setValue:@(number) forKey:@"goodsNum"];
        [dict setValue:[model.dataDic objectForKey:@"id"] forKey:@"id"];
        [HttpTools Post:kAppendUrl(YWEditShopCarString) parameters:dict success:^(id responseObject) {
            
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }];
        
        model.selectNumber = number;
        completeBlock(NO);
    };
    
    _selectBtn.selected = model.isSelect;
    [[[_selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
      
        if (model.isEditing) {
            x.selected = !x.selected;
            model.isSelect = x.selected;
            completeBlock(YES);
            weakSelf.clickSelectBtn(x.selected);
        }else{
            if (model.isWuHuo || model.isShiXiao) {
                x.selected = NO;
                model.isSelect = NO;
                [SVProgressHUD showInfoWithStatus:@"无货商品无法选择"];
            } else {
                x.selected = !x.selected;
                model.isSelect = x.selected;
                completeBlock(YES);
                weakSelf.clickSelectBtn(x.selected);
            }
        }
        
        
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [[[tapGesture rac_gestureSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        
        if ([[model.dataDic objectForKey:@"state"] integerValue] == 1) {
            [SVProgressHUD showInfoWithStatus:@"该商品已无货！"];
            return;
        }
        
        NSArray *skuArr = [[model.dataDic objectForKey:@"goodsDetails"] objectForKey:@"goodsSpecificationDetails"];
        if (skuArr.count <= 1) {
            [SVProgressHUD showInfoWithStatus:@"没有其他规格可供选择！"];
            return;
        }
        SkuSelectView *skuSelectView = [[SkuSelectView alloc] init];
        skuSelectView.skusArr = skuArr;
        skuSelectView.selectedSkuByShop = ^(NSDictionary *skuDic, NSInteger selectNum, NSInteger skuType) {
            
            model.skuSelectedDic = skuDic;
            model.selectNumber = selectNum;
            model.price = [skuDic objectForKey:@"price"];
            model.goodsImageUrl = [[[skuDic objectForKey:@"goodsDisplayPictures"] firstObject] objectForKey:@"picUrl"];
            completeBlock(YES);
            
            
            NSNumber *userID = [YWUserDefaults objectForKey:@"UserID"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:userID forKey:@"userId"];
            [dict setValue:@"-1" forKey:@"operation"];
            [dict setValue:[model.skuSelectedDic objectForKey:@"id"] forKey:@"goodsSpecificationDetailsId"];
            [dict setValue:@(model.selectNumber) forKey:@"goodsNum"];
            [dict setValue:[model.dataDic objectForKey:@"id"] forKey:@"id"];
            [HttpTools Post:kAppendUrl(YWEditShopCarString) parameters:dict success:^(id responseObject) {
                
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"修改失败"];
            }];
            
        };
        
    }];
    
    [_specBackView addGestureRecognizer:tapGesture];
    
    if (model.isEditing) {
        _specBackView.backgroundColor = kBackGrayColor;
        _specBackView.userInteractionEnabled = YES;
        _specImageView.hidden = NO;
//        _AmountTextField.hidden = NO;
    } else {
        _specBackView.backgroundColor = [UIColor whiteColor];
        _specBackView.userInteractionEnabled = NO;
        _specImageView.hidden = YES;
//        _AmountTextField.hidden = YES;
    }
    
    if (model.isShiXiao) {
        if(!model.isEditing){
            self.saleOutImageView.hidden = NO;
            self.AmountTextField.userInteractionEnabled = NO;
            model.isSelect = NO;
            _selectBtn.selected = NO;
        }
        
    } else {
        self.AmountTextField.userInteractionEnabled = YES;
        self.saleOutImageView.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_activeTagLab setBorder:kRedTextColor width:1.f radius:5.f];
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

 }

@end
