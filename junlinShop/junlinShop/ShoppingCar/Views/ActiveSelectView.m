//
//  ActiveSelectView.m
//  junlinShop
//
//  Created by 叶旺 on 2018/3/31.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ActiveSelectView.h"

@interface ActiveSelectView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *activeArray;
@property (nonatomic) BOOL isOnlyShow;

@end

@implementation ActiveSelectView

+ (instancetype)initWithActiveArray:(NSArray *)activeArray isShow:(BOOL)isShow {
    ActiveSelectView *activeView = [[ActiveSelectView alloc] init];
    activeView.activeArray = activeArray;
    activeView.isOnlyShow = isShow;
    return activeView;
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kIphoneWidth, kIphoneHeight);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap rac_gestureSignal] subscribeNext:^(id x) {
            [self removeFromSuperview];
        }];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [self createUI];
        
        [YWWindow addSubview:self];
    }
    return self;
}

- (void)createUI {
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, kIphoneHeight / 2, kIphoneWidth, kIphoneHeight / 2)];
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"订单商品所参与的活动";
    titleLab.textColor = kBlackTextColor;
    titleLab.font = [UIFont systemFontOfSize:15.f];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView.mas_centerX);
        make.top.equalTo(backView.mas_top).offset(10);
        make.width.equalTo(@160);
        make.height.equalTo(@30);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"picture_delete"] forState:UIControlStateNormal];
    [[closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self removeFromSuperview];
    }];
    [backView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backView.mas_right).offset(-15);
        make.centerY.equalTo(titleLab.mas_centerY);
        make.width.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    UILabel *tipsLab = [[UILabel alloc] init];
    tipsLab.text = @"提示：购买数量大于活动最大购买数量时，超出数量按照原价进行计算。";
    tipsLab.numberOfLines = 2;
    tipsLab.font = [UIFont systemFontOfSize:14.f];
    tipsLab.textColor = kGrayTextColor;
    [backView addSubview:tipsLab];
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView.mas_centerX);
        make.bottom.equalTo(backView.mas_bottom);
        make.left.equalTo(backView.mas_left).offset(5);
        make.height.equalTo(@50);
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kBackViewColor;
    [backView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLab.mas_bottom).offset(10);
        make.left.right.equalTo(backView);
        make.bottom.equalTo(tipsLab.mas_top);
    }];
}

- (void)drawRect:(CGRect)rect {
    [self.tableView reloadData];
}

#pragma mark tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activeArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchTableViewCell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *activeView = [self createActiveViewWithDic:_activeArray[indexPath.row]];
    activeView.frame = CGRectMake(16, 5, kIphoneWidth - 32, 40);
    [cell.contentView addSubview:activeView];
    
    return cell;
}

- (UIView *)createActiveViewWithDic:(NSDictionary *)dic {
    
    NSDictionary *activeDic = [dic objectForKey:@"activityInformation"];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(60, 1, kIphoneWidth - 80, 44)];
    
    UILabel *tagLab = [[UILabel alloc] init];
    tagLab.font = [UIFont systemFontOfSize:13.f];
    tagLab.textAlignment = NSTextAlignmentCenter;
    [tagLab setBorder:kRedTextColor width:1.f radius:4.f];
    tagLab.textColor = kRedTextColor;
    [backView addSubview:tagLab];
    [tagLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
        make.left.equalTo(backView.mas_left).offset(2);
        make.width.equalTo(@(40));
        make.height.equalTo(@(18));
    }];
    
    UILabel *detailLab = [[UILabel alloc] init];
    detailLab.font = [UIFont systemFontOfSize:13.f];
    detailLab.numberOfLines = 2;
    detailLab.textColor = kGrayTextColor;
    [backView addSubview:detailLab];
    [detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
        make.left.equalTo(tagLab.mas_right).offset(5);
        make.right.equalTo(backView.mas_right).offset(-15);
        make.height.equalTo(@(40));
    }];
    
    NSString *activeStr = nil;
    switch ([[activeDic objectForKey:@"activityType"] intValue]) {
        case 0:
            tagLab.text = @"折扣";
            activeStr = [NSString stringWithFormat:@"打%.1f折,最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue] * 10, [activeDic objectForKey:@"maxNum"]];
            break;
        case 1:
            tagLab.text = @"团购";
            activeStr = [NSString stringWithFormat:@"团购单价为%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
            break;
        case 2:
            tagLab.text = @"秒杀";
            activeStr = [NSString stringWithFormat:@"秒杀单价为%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
            break;
        case 3:
            tagLab.text = @"立减";
            activeStr = [NSString stringWithFormat:@"立减%.2f元，最多购买%@个", [[activeDic objectForKey:@"discount"] floatValue], [activeDic objectForKey:@"maxNum"]];
            break;
        case 4:
            tagLab.text = @"满减";
            activeStr = [NSString stringWithFormat:@"满%.2f元，可减%.2f元", [[activeDic objectForKey:@"price"] floatValue], [[activeDic objectForKey:@"discount"] floatValue]];
            break;
        case 5:
            tagLab.text = @"预售";
            activeStr = [NSString stringWithFormat:@"预售活动（%@-%@）", [ASHString jsonDateToString:[activeDic objectForKey:@"beginValidityTime"] withFormat:@"yyyy.MM.dd"],[ASHString jsonDateToString:[activeDic objectForKey:@"endValidityTime"] withFormat:@"yyyy.MM.dd"]];
            break;
        default:
            break;
    }
    
    detailLab.text = [NSString stringWithFormat:@"%@ %@", [activeDic objectForKey:@"name"], activeStr];
    
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isOnlyShow) {
        return;
    }
    NSDictionary *dict = _activeArray[indexPath.row];
    self.completeSelectActive(dict);
    [self removeFromSuperview];
}

#pragma mark 点击冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"]) {
        return NO;
    }
    return  YES;
}
 

@end
