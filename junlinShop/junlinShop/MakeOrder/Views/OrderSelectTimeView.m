//
//  OrderSelectTimeView.m
//  junlinShop
//
//  Created by jianxuan on 2018/2/7.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "OrderSelectTimeView.h"
#import "Masonry.h"
#import "UIView+ALWAdd.h"
#import <ReactiveObjC.h>
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>

#define cellHeight (((_dateArray.count + 2) / 3) * 32 + 16)
@interface OrderSelectTimeView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation OrderSelectTimeView

- (instancetype)initWithEndTime:(NSNumber *)endTime {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.endDateNum = endTime;
        
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        requireBtn.backgroundColor = kBackGreenColor;
        [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
        [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requireBtn addTarget:self action:@selector(clickRequireBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:requireBtn];
        [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@45);
        }];
        
        self.tableView.backgroundColor = kBackViewColor;
        _selectedIndex = 0;
        
        NSMutableArray *array = [NSMutableArray array];
        
        if (_endDateNum == nil) {
            for (int i = 0; i < 8; i ++) {
                NSDate *date = [NSDate date];
                NSDate *newDate = [NSDate dateWithTimeInterval:24 * 3600 * i sinceDate:date];
                NSString *dateStr = [ASHString NSDateToString:newDate withFormat:@"yyyy-MM-dd"];
                [array addObject:dateStr];
            }
        } else {
            [array addObject:[ASHString jsonDateToString:_endDateNum withFormat:@"yyyy-MM-dd"]];
        }
        self.dateArray = array;
        
        [YWWindow addSubview:self];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 36)];
        _headerView.backgroundColor = kBackViewColor;
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, kIphoneWidth - 100, 20)];
        titleLab.text = @"选择送货时间";
        titleLab.textColor = kBlackTextColor;
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:18];
        [_headerView addSubview:titleLab];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(kIphoneWidth - 30, 12, 20, 20);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"deletePicture"] forState:UIControlStateNormal];
        [_headerView addSubview:deleteBtn];
        
        YWWeakSelf;
        [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            [weakSelf removeFromSuperview];
        }];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        
        [self addSubview:_tableView];
        
        self.tableView.tableHeaderView = self.headerView;
        
    }
    return _tableView;
}

#pragma mark 事件处理
- (void)clickRequireBtn:(UIButton *)button {
    NSString *dateStr = _dateArray[_selectedIndex];
    if (!_endDateNum) {
        self.selectedDateStr(dateStr);
    }
    [self removeFromSuperview];
}



#pragma mark setter
- (void)setDateArray:(NSArray *)dateArray {
    _dateArray = dateArray;
    CGFloat height = cellHeight + 36;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-45);
        make.height.equalTo(@(height));
    }];
    [self.tableView reloadData];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SkuSelectCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SkuSelectCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    YWWeakSelf;
    CGFloat btnWidth = (kIphoneWidth - 30)/ 3;
    for (int i = 0; i < _dateArray.count; i ++) {
        NSString *tagStr = _dateArray[i] ;
        
        UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [tagBtn setTitle:tagStr forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tagBtn setTitleColor:kBackGreenColor forState:UIControlStateSelected];
        [tagBtn setBorder:[UIColor lightGrayColor] width:1.f radius:4.f];
        
        tagBtn.tag = 1000 + i;
        tagBtn.frame = CGRectMake(15 + btnWidth * (i % 3), 10 + 32 * (i / 3), btnWidth - 10, 26);
        [cell.contentView addSubview:tagBtn];
        
        if (_selectedIndex == i) {
            tagBtn.selected = YES;
            [tagBtn setBorder:kBackGreenColor width:1.f radius:4.f];
        }
        
        if (_endDateNum) {
            tagBtn.frame = CGRectMake(15, 10, kIphoneWidth - 30, 26);
            
            [tagBtn setTitle:[NSString stringWithFormat:@"送货时间为活动结束后7日内（结束时间：%@）", tagStr] forState:UIControlStateNormal];
        }
        
        [[[tagBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            for (UIView *view in x.superview.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)view;
                    btn.selected = NO;
                    [btn setBorder:[UIColor lightGrayColor] width:1.f radius:4.f];
                }
            }
            x.selected = YES;
            [tagBtn setBorder:kBackGreenColor width:1.f radius:4.f];
            weakSelf.selectedIndex = x.tag - 1000;
            
        }];
        
    }
    
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
