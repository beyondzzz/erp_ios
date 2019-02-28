//
//  HomeTitleView.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/26.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "HomeTitleView.h"
#import "YWSearchBar.h"

@implementation HomeTitleView


- (instancetype)initWithLocation:(NSString *)locationStr HasNotice:(BOOL)hasNotice {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kIphoneWidth, SafeAreaTopHeight);
//        self.backgroundColor = kBackGreenColor;
        self.backgroundColor = [UIColor blackColor];
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationBtn setImage:[UIImage imageNamed:@"home_locate_iocn"] forState:UIControlStateNormal];
        [_locationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_locationBtn setTitle:locationStr forState:UIControlStateNormal];
        _locationBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_locationBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:1.f];
        [self addSubview:_locationBtn];
        [_locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(5);
            make.centerY.equalTo(self.mas_centerY).offset(5);
            make.width.equalTo(@70);
            make.height.equalTo(@30);
        }];
        
        YWSearchBar *searchBar = [[YWSearchBar alloc] initWithFrame:CGRectMake(100, 20, 120, 30) andStyle:YWSearchBarStyleGrayColor];
        searchBar.delegate = self;
        [self addSubview:searchBar];
        [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_locationBtn.mas_right).offset(5);
            make.centerY.equalTo(self.mas_centerY).offset(5);
            make.right.equalTo(self.mas_right).offset(-50);
            make.height.equalTo(@30);
        }];
        
        UIView *rightView = [[UIView alloc] init];
        rightView.backgroundColor = [UIColor whiteColor];
        [rightView setRadius:40.f];
        
        _noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _noticeBtn.frame = CGRectMake(0, 0, 25, 24);
        [_noticeBtn setBackgroundImage:[UIImage imageNamed:@"home_notice_iocn"] forState:UIControlStateNormal];
        [_noticeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_noticeBtn];
        [_noticeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right).offset(-45);
            make.centerY.equalTo(self.mas_centerY).offset(5);
            make.width.equalTo(@30);
            make.height.equalTo(@30);
        }];
        if (hasNotice) { 
//            _noticeBtn.badgeValue = @" ";
        }
    }
    return self;
}

#pragma mark searchBar代理
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.clickSearchBar();
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
