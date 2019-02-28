//
//  DropdownTagSelectView.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/22.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "DropdownTagSelectView.h"
#import "SelectCollectionViewCell.h"

#define kItemWidth ((kIphoneWidth - 60) / 4)
@interface DropdownTagSelectView() <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) BrandComplete brandComplete;
@property (nonatomic, copy) TableSelectComplete tableComplete;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *selectIndexArray;
@property (nonatomic) CGFloat backViewHeight;
@property (nonatomic) DropdownTagViewType viewType;

@end

@implementation DropdownTagSelectView

+ (instancetype)initWithDataArray:(NSArray *)dataArray andType:(DropdownTagViewType)type andCompleteBlock:(BrandComplete)complete orTableSelectComplete:(TableSelectComplete)tableComplete {
    
    DropdownTagSelectView *screenView = [[DropdownTagSelectView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight + 45, kIphoneWidth, kIphoneHeight - SafeAreaTopHeight - 45 - SafeAreaBottomHeight)];
    screenView.dataArray = dataArray;
    
    if (type == DropdownTagViewTypeCollection) {
        screenView.brandComplete = complete;
        screenView.backViewHeight = ((dataArray.count + 3) / 4) * 40.0 + 60;
    } else {
        screenView.tableComplete = tableComplete;
        screenView.backViewHeight = dataArray.count * 36.0 + 5 + (dataArray.count - 1);
    }
    screenView.viewType = type;
     [YWWindow addSubview:screenView];
    
    return screenView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScreenView)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        [self addSubview:self.backView];
        
        _selectIndexArray = (NSMutableArray *)[[CacheManager share].commonCache objectForKey:SelectBrandArray];
        if (IsArrEmpty(_selectIndexArray)) {
            _selectIndexArray = [NSMutableArray array];
            
        }
     }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    _backView.frame = CGRectMake(0, 0, kIphoneWidth, _backViewHeight);
    UIView *secondLine = [_backView viewWithTag:1001];
    UIView *thirdLine = [_backView viewWithTag:1002];
    UIButton *resetBtn = [_backView viewWithTag:1003];
    UIButton *requireBtn = [_backView viewWithTag:1004];
    
    
    if (_viewType == DropdownTagViewTypeTable) {
        resetBtn.hidden = YES;
        requireBtn.hidden = YES;
        secondLine.hidden = YES;
        thirdLine.hidden = YES;
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(_backView.mas_top);
            make.bottom.equalTo(_backView.mas_bottom);
            make.left.equalTo(_backView.mas_left);
        }];
    } else {
        resetBtn.hidden = NO;
        requireBtn.hidden = NO;
        secondLine.hidden = NO;
        thirdLine.hidden = NO;
        
        [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_backView.mas_left);
            make.bottom.equalTo(_backView.mas_bottom).offset(-45);
            make.right.equalTo(_backView.mas_right);
            make.height.equalTo(@0.5);
        }];
        
        [thirdLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.bottom.equalTo(_backView.mas_bottom);
            make.top.equalTo(secondLine.mas_bottom);
            make.width.equalTo(@1);
        }];
        
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_backView.mas_left);
            make.bottom.equalTo(_backView.mas_bottom);
            make.right.equalTo(thirdLine.mas_left);
            make.top.equalTo(secondLine.mas_bottom);
        }];
        
        [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thirdLine.mas_right);
            make.bottom.equalTo(_backView.mas_bottom);
            make.right.equalTo(_backView.mas_right);
            make.top.equalTo(secondLine.mas_bottom);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(_backView.mas_top);
            make.bottom.equalTo(secondLine.mas_top);
            make.left.equalTo(_backView.mas_left);
        }];
    }
    
    
    
//    [UIView animateWithDuration:1.0 animations:^{
//        self.backView.frame = CGRectMake(0, 0, kIphoneWidth, _backViewHeight);
//    }];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
//        _backView.layer.masksToBounds = YES;
        _backView.clipsToBounds = YES;
//        _backView.layer.cornerRadius = 8;
        
        UIView *secondLine = [[UIView alloc] init];
        secondLine.tag = 1001;
        secondLine.backgroundColor = kGrayLineColor;
        [_backView addSubview:secondLine];
        
        UIView *thirdLine = [[UIView alloc] init];
        thirdLine.tag = 1002;
        thirdLine.backgroundColor = kGrayLineColor;
        [_backView addSubview:thirdLine];
        
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.tag = 1003;
        [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [resetBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        [resetBtn addTarget:self action:@selector(resetSelect) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:resetBtn];
        
        
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        requireBtn.tag = 1004;
        [requireBtn setTitle:@"确认" forState:UIControlStateNormal];
        [requireBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(kIphoneWidth / 2, 50) andColor:kBackGreenColor] forState:UIControlStateNormal];
        [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requireBtn addTarget:self action:@selector(completeSelect) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:requireBtn];
        
        
        [_backView addSubview:self.collectionView];
        
    }
    return _backView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, kIphoneWidth, 100) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"SelectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SelectCollectionViewCell"];
    }
    return _collectionView;
}

- (void)dismissScreenView {
    [self removeFromSuperview];
}

- (void)resetSelect {
    [_selectIndexArray removeAllObjects];
    [[CacheManager share].commonCache removeObjectForKey:SelectBrandArray];
    [_collectionView reloadData];
}

- (void)completeSelect {
    
    if (_viewType == DropdownTagViewTypeCollection) {
        
        NSMutableArray *brandArr = [NSMutableArray array];
        for (NSIndexPath *indexP in _selectIndexArray) {
            [brandArr addObject:_dataArray[indexP.row]];
        }
        self.brandComplete(brandArr);
        
    } else {
        self.brandComplete(nil);
    }
    [self dismissScreenView];
}

#pragma mark CollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_viewType == DropdownTagViewTypeCollection) {
        return CGSizeMake(kItemWidth, 30);
    }
    return CGSizeMake(kIphoneWidth, 36);
}


//定义每个Section /collectionView(指定区)的边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (_viewType == DropdownTagViewTypeTable) {
        return UIEdgeInsetsMake(5, 0, 0, 0);
    }
    return UIEdgeInsetsMake(10, 15, 15, 15);
    
}

//设定指定区内Cell的最小行距，也可以直接设置UICollectionViewFlowLayout的minimumLineSpacing属性
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (_viewType == DropdownTagViewTypeTable) {
        return 1;
    }
    return 10;
}

//..设定指定区内Cell的最小间距，也可以直接设置UICollectionViewFlowLayout的minimumInteritemSpacing属性
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectCollectionViewCell" forIndexPath:indexPath];
    
    NSString *brandStr = self.dataArray[indexPath.row];
        
    if ([_selectIndexArray containsObject:indexPath]) {
        [cell setBrandStr:brandStr isSelected:YES];
    } else {
        [cell setBrandStr:brandStr isSelected:NO];
    }
    
    if (_viewType == DropdownTagViewTypeTable) {
        [cell.backView setBorder:[UIColor clearColor] width:1 radius:1];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_viewType == DropdownTagViewTypeCollection) {
        if (_selectIndexArray.count == 0) {
            [_selectIndexArray addObject:indexPath];
        } else {
            BOOL hasIndex = [_selectIndexArray containsObject:indexPath];
            if (hasIndex) {
                [_selectIndexArray removeObject:indexPath];
            } else {
                [_selectIndexArray addObject:indexPath];
            }
        }
        [[CacheManager share].commonCache setObject:_selectIndexArray forKey:SelectBrandArray];
        
        [UIView performWithoutAnimation:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        }];
    } else {
//        [_selectIndexArray addObject:indexPath];
        NSString *str = _dataArray[indexPath.row];
        self.tableComplete(str);
//        self.brandComplete(weakSelf.selectIndexArray);
        [self dismissScreenView];
    }
}

#pragma mark 点击冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UICollectionView"]) {
        return NO;
    }
    return  YES;
}

- (void)dealloc {
    NSLog(@"dealloc");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
