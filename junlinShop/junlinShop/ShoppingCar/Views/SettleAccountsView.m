//
//  SettleAccountsView.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SettleAccountsView.h"
#import "UIImage+YWExtension.h"

@interface SettleAccountsView ()

@property (nonatomic, copy) NSString *titleStr;

@end

@implementation SettleAccountsView

+ (instancetype)initWithButtonTitle:(NSString *)title hasTabBar:(BOOL)hasTabBar {
    NSInteger bottom = 0;
    if (hasTabBar) {
        bottom = 49;
    }
    SettleAccountsView *accountView = [[SettleAccountsView alloc] initWithFrame:CGRectMake(0, kIphoneHeight - SafeAreaTopHeight - SafeAreaBottomHeight - 45 - bottom, kIphoneWidth, 45)];
    accountView.titleStr = title;
    
    return accountView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = kBackViewColor;
        
        [YWNoteCenter addObserver:self selector:@selector(changePrice:) name:@"ChangeTotlePrice" object:nil];
        
        UIView *firstLine = [[UIView alloc] init];
        firstLine.backgroundColor = kGrayLineColor;
        [self addSubview:firstLine];
        [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(@0.5);
        }];
        
        _accountsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accountsBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(100, 50) andColor:kBackGreenColor] forState:UIControlStateSelected];
        [_accountsBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(100, 50) andColor:kGrayTextColor] forState:UIControlStateNormal];
        [self addSubview:_accountsBtn];
        [_accountsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.width.equalTo(@90);
            make.top.equalTo(self.mas_top);
        }];
        
      
        
        UILabel *totleLab = [[UILabel alloc] init];
        totleLab.text = @"合计";
        totleLab.textColor = kGrayTextColor;
        totleLab.textAlignment = NSTextAlignmentRight;
        totleLab.font = [UIFont systemFontOfSize:12];
        [self addSubview:totleLab];
        [totleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
            make.width.equalTo(@30);
         }];
 
   
        
        _totlePriceLab = [[UILabel alloc] init];
        _totlePriceLab.textColor = kBackYellowColor;
//        _totlePriceLab.backgroundColor = UIColor.grayColor;

        _totlePriceLab.font = [UIFont systemFontOfSize:17];
        [self addSubview:_totlePriceLab];
        [_totlePriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(totleLab.mas_right);
            make.centerY.equalTo(totleLab.mas_centerY);
            make.width.equalTo(@100);
         }];
        
        _tipLab = [[UILabel alloc] init];
        _tipLab.text = @"不含运费";
        _tipLab.textColor =   kGrayTextColor;
        _tipLab.textAlignment = NSTextAlignmentCenter;
//        _tipLab.backgroundColor = UIColor.redColor;
        _tipLab.font = [UIFont systemFontOfSize:11];
        [self addSubview:_tipLab];
        [_tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_totlePriceLab.mas_right);
            make.centerY.equalTo(totleLab.mas_centerY);
            make.right.equalTo(_accountsBtn.mas_left);
         }];
    }
    return self;
}

- (void)setCarriage:(CGFloat)carriage {
     if (carriage == - 1.f) {
        _tipLab.text = @"运费到付";
    } else if(carriage >=0){
        _carriage = carriage;
        _tipLab.text = [NSString stringWithFormat:@"含运费：¥%.2f", carriage];
    }else{
        LLFunc()
        dispatch_main_async_safe(^{
            _tipLab.text = @"订单超出配送范围，运费货到付款";
        });
        

    }
}

- (void)drawRect:(CGRect)rect {
    
    [_accountsBtn setTitle:_titleStr forState:UIControlStateNormal];
    if ([_titleStr isEqualToString:@"提交订单"]) {
        _accountsBtn.selected = YES;
    }
}

- (void)changePrice:(NSNotification *)noti {
    NSDictionary *dict = noti.object;
    _totlePriceLab.text = [dict objectForKey:@"totlePrice"];
    
    if ([_titleStr containsString:@"结算"]) {
        [_accountsBtn setTitle:[NSString stringWithFormat:@"结算(%@)", [dict objectForKey:@"selectCount"]] forState:UIControlStateNormal];
        if ([[dict objectForKey:@"selectCount"] integerValue] > 0) {
            _accountsBtn.selected = YES;
        } else {
            _accountsBtn.selected = NO;
        }
    }
}



@end
