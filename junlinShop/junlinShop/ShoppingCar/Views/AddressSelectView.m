//
//  AddressSelectView.m
//  junlinShop
//
//  Created by 叶旺 on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "AddressSelectView.h"
#import "UIImage+YWExtension.h"

#define rowHeight 45
@interface AddressSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray *addressArray;

@end

@implementation AddressSelectView

- (instancetype)initAddressArray:(NSArray *)addressArray complete:(CompleteSelect)complete {
    if (self = [super init]) {
        
        self.frame = CGRectMake(0, SafeAreaTopHeight, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        [self createUIWithArray:addressArray andCompleteBlock:complete];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(id x) {
            [self removeFromSuperview];
        }];
        [self addGestureRecognizer:tap];
        
        [YWWindow addSubview:self];
    }
    return self;
}

- (void)createUIWithArray:(NSArray *)array andCompleteBlock:(CompleteSelect)complete {
    _addressArray = array;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(kIphoneWidth, 0, kIphoneWidth, rowHeight * 6 + 10)];
    backView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"配送至";
    titleLab.textColor = kBlackTextColor;
    titleLab.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView.mas_centerX);
        make.top.equalTo(backView.mas_top).offset(10);
        make.width.equalTo(@100);
        make.height.equalTo(@30);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [[closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self removeFromSuperview];
    }];
    [backView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backView.mas_right).offset(-15);
        make.centerY.equalTo(titleLab.mas_centerY);
        make.width.equalTo(@24);
        make.height.equalTo(@24);
    }];
    
//    UIView *firstLine = [[UIView alloc] init];
//    firstLine.backgroundColor = kGrayLineColor;
//    [backView addSubview:firstLine];
//    [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(backView.mas_centerX);
//        make.top.equalTo(titleLab.mas_bottom).offset(10);
//        make.right.equalTo(backView.mas_right);
//        make.height.equalTo(@0.5);
//    }];
    
    UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [requireBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(kIphoneWidth, 50) andColor:kBackGreenColor] forState:UIControlStateNormal];
    [requireBtn setTitle:@"选择其他地址" forState:UIControlStateNormal];
    [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[requireBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        complete(array[_selectedIndex]);
        [self removeFromSuperview];
    }];
    [backView addSubview:requireBtn];
    [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backView.mas_right);
        make.left.equalTo(backView.mas_left);
        make.bottom.equalTo(backView.mas_bottom);
        make.height.equalTo(@50);
    }];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, rowHeight + 5, kIphoneWidth, array.count * rowHeight) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = kBackViewColor;
    tableView.scrollEnabled = NO;
    [backView addSubview:tableView];
}

#pragma mark tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _addressArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchTableViewCell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
