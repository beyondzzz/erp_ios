//
//  HomeTitleView.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/26.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTitleView : UIView <UISearchBarDelegate>

@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIButton *noticeBtn;
@property (nonatomic, copy) void (^clickSearchBar)(void);

- (instancetype)initWithLocation:(NSString *)locationStr HasNotice:(BOOL)hasNotice;

@end
