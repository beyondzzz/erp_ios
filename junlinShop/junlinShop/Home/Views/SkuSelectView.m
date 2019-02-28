//
//  SkuSelectView.m
//  ShopApp
//
//  Created by jianxuan on 2018/1/15.
//  Copyright © 2018年 Sorry. All rights reserved.
//

#import "SkuSelectView.h"
#import "Masonry.h"
#import "UIView+ALWAdd.h"
#import <ReactiveObjC.h>
#import "UIImageView+WebCache.h"
#import <SVProgressHUD.h>
#import "TQAmountTextField.h"

@interface SkuSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) TQAmountTextField *amountField;

@end

@implementation SkuSelectView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelf)];
        [self addGestureRecognizer:gesture];
        
        _selectNum = 1;
        
        UIView *lineView = [[UIView alloc] init];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-44);
            make.height.equalTo(@(0.5));
        }];
        
        UIView *countBackView = [[UIView alloc] init];
        countBackView.backgroundColor = [UIColor whiteColor];
        [self addSubview:countBackView];
        [countBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(lineView.mas_top);
            make.height.equalTo(@36);
        }];
        
        UILabel *countLab = [[UILabel alloc] init];
        countLab.text = @"数量";
        countLab.font = [UIFont systemFontOfSize:15];
        [countBackView addSubview:countLab];
        [countLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.centerY.equalTo(countBackView.mas_centerY);
            make.height.equalTo(@20);
        }];
        
        _amountField = [[TQAmountTextField alloc] initWithFrame:CGRectMake(kIphoneWidth - 110, 3, 100, 30)];
        [_amountField setBorder:kGrayLineColor width:1.f radius:5.f];
        _amountField.buyMinNumber = _selectNum;
        _amountField.stepLength = 1;
        
        YWWeakSelf;
        _amountField.changeNumber = ^(NSInteger number) {
            weakSelf.selectNum = number;
        };
        [countBackView addSubview:_amountField];
        
        self.tableView.backgroundColor = kBackViewColor;
        _selectedIndex = 0;
        [YWWindow addSubview:self];
        
        [self addKeyBoardNotification];
    }
    return self;
}

- (void)setSkuDic:(NSDictionary *)skuDic {
    if (skuDic && _skusArr.count > 0) {
        NSInteger index = [_skusArr indexOfObject:skuDic];
        _selectedIndex = index;
        _amountField.buyMinNumber = _selectNum;
        [self setHeaderViewValue];
        [self.tableView reloadData];
    }
}

- (void)addKeyBoardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGFloat keyboardHeight = frame.size.height;
    self.frame = CGRectMake(0, - keyboardHeight, kIphoneWidth, kIphoneHeight);
    
}

-(void)keyboardWillHidden:(NSNotification *)notification
{
    //    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        [self layoutIfNeeded];
        self.frame = [UIScreen mainScreen].bounds;
    }];
    
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kIphoneWidth, 75)];
        _headerView.backgroundColor = kBackViewColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, -15 , 80, 80)];
        imageView.image = kDefaultImage;
        imageView.tag = 1200;
        [_headerView addSubview:imageView];
        
        UILabel *priceLab = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, kIphoneWidth - 150, 20)];
        priceLab.text = @"¥";
        priceLab.tag = 1201;
        priceLab.textColor = [UIColor redColor];
        priceLab.font = [UIFont systemFontOfSize:16];
        [_headerView addSubview:priceLab];
        
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
        
        [self addSubview:_tableView];
        
        [self addSubview:self.headerView];

    }
    return _tableView;
}

- (void)drawRect:(CGRect)rect {
    YWWeakSelf;
    if (!_type) {
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        requireBtn.backgroundColor = kBackGreenColor;
        [requireBtn setTitle:@"确定" forState:UIControlStateNormal];
        [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requireBtn addTarget:self action:@selector(clickRequireBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:requireBtn];
        [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@(44));
        }];
    } else {
        
        UIButton *shopCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shopCarBtn.backgroundColor = kBackGreenColor;
        [shopCarBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
        [shopCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[shopCarBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        weakSelf.selectedSkuByShop(weakSelf.skusArr[weakSelf.selectedIndex], weakSelf.selectNum, 1);
            [weakSelf removeFromSuperview];
        }];
        [self addSubview:shopCarBtn];
        [shopCarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.equalTo(@(kIphoneWidth / 2));
            make.bottom.equalTo(self);
            make.height.equalTo(@(44));
        }];
        
        UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyBtn.backgroundColor = kBackYellowColor;
        [buyBtn setTitle:@"立即购买" forState:UIControlStateNormal];
        [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[buyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        weakSelf.selectedSkuByShop(weakSelf.skusArr[weakSelf.selectedIndex], weakSelf.selectNum, 2);
            [weakSelf removeFromSuperview];
        }];
        [self addSubview:buyBtn];
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.width.equalTo(@(kIphoneWidth / 2));
            make.bottom.equalTo(self);
            make.height.equalTo(@(44));
        }];
    }
}

#pragma mark 事件处理
- (void)dismissSelf {
    NSDictionary *selectDic = _skusArr[_selectedIndex];
    NSInteger num = _selectNum;
    self.selectedSkuByShop(selectDic, num, 4);
    [self removeFromSuperview];
}

- (void)clickRequireBtn:(UIButton *)button {
    NSDictionary *selectDic = _skusArr[_selectedIndex];
    NSInteger num = _selectNum;
    self.selectedSkuByShop(selectDic, num, 3);
    [self removeFromSuperview];
}

- (void)setHeaderViewValue {
    NSDictionary *selectDic = _skusArr[_selectedIndex];
    UIImageView *imageView = [_headerView viewWithTag:1200];
    UILabel *priceLab = [_headerView viewWithTag:1201];
    
    NSArray *picArr = [selectDic objectForKey:@"goodsDisplayPictures"];
    NSString *urlStr = kAppendUrl([[picArr firstObject] objectForKey:@"picUrl"]);
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:kDefaultImage];
    priceLab.text = [NSString stringWithFormat:@"¥ %.2f", [[selectDic objectForKey:@"price"] floatValue]];
    
}

#pragma mark setter
- (void)setSkusArr:(NSArray *)skusArr {
    _skusArr = skusArr;
    [self setHeaderViewValue];
    
    CGFloat height = 50 + ((_skusArr.count + 2) / 3) * 32;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-80);
        make.height.equalTo(@(height));
    }];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@80);
        make.bottom.equalTo(self.tableView.mas_top);
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
    return 45 + ((_skusArr.count + 2) / 3) * 32;
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
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kIphoneWidth - 30, 20)];
    titleLab.text = @"种类";
    titleLab.font = [UIFont systemFontOfSize:15];
    [cell addSubview:titleLab];
    
    YWWeakSelf;
    CGFloat btnWidth = (kIphoneWidth - 30)/ 3;
    for (int i = 0; i < _skusArr.count; i ++) {
        NSString *tagStr = [_skusArr[i] objectForKey:@"specifications"];
        
        UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [tagBtn setTitle:tagStr forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tagBtn setTitleColor:kBackGreenColor forState:UIControlStateSelected];
        [tagBtn setBorder:[UIColor lightGrayColor] width:1.f radius:4.f];
        
        tagBtn.tag = 1000 + i;
        tagBtn.frame = CGRectMake(15 + btnWidth * (i % 3), 40 + 32 * (i / 3), btnWidth - 10, 26);
        [cell.contentView addSubview:tagBtn];
        
        if (_selectedIndex == i) {
            tagBtn.selected = YES;
            [tagBtn setBorder:kBackGreenColor width:1.f radius:4.f];
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
            
            [weakSelf setHeaderViewValue];
        }];
        
    }
    
    return cell;
}

- (void)dealloc {
    [YWNoteCenter removeObserver:self];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
