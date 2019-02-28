//
//  TagScreenView.m
//  simple
//
//  Created by jianxuan on 2017/11/20.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "TagScreenView.h"
#import "ClassifyListModel.h"
#import "SelectCollectionViewCell.h"

#define backViewWidth (kIphoneWidth - 70)
#define cellSize CGSizeMake((backViewWidth - 50) / 3, 30)


@interface TagScreenView () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) ScreenComplete screenComplete;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UICollectionView *topCollectionView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITextField *minPriceField;
@property (nonatomic, strong) UITextField *maxPriceField;
@property (nonatomic, strong) UIButton *stocksBtn;
@property (nonatomic, strong) NSMutableArray *selectIndexArray;
@property (nonatomic, strong) GoodsTypeSelectModel *selectModel;

@property (nonatomic) BOOL isShowInStore; //有货
@property (nonatomic) BOOL isShowSale; //促销
@property (nonatomic) BOOL isShowAllBrands;
@property (nonatomic) BOOL isShowAllClassfiy;


@end

@implementation TagScreenView

+ (instancetype)initWithDataArray:(NSArray *)dataArray andGoodTypeModel:(GoodsTypeSelectModel *)typeModel andCompleteBlock:(ScreenComplete)complete {
    
    TagScreenView *screenView = [[TagScreenView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    screenView.dataArray = dataArray;
    screenView.screenComplete = complete;
    screenView.selectModel = typeModel;

    [YWWindow addSubview:screenView];
    
    return screenView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _isShowInStore = YES;//默认有货
        _isShowSale = NO;
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissScreenView)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        [self addSubview:self.backView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.frame = CGRectMake(70, 0, backViewWidth, kIphoneHeight);
        }];
        
        
        _selectIndexArray = (NSMutableArray *)[[CacheManager share].commonCache objectForKey:SelectIndexArray];
         if (IsArrEmpty(_selectIndexArray)) {
            _selectIndexArray = [NSMutableArray array];

        }
        
        NSLog(@"及分工%@",(NSString *)[[CacheManager share].commonCache objectForKey:SelectMinPrice]);
        NSString *minPrice  =  (NSString *)[[CacheManager share].commonCache objectForKey:SelectMinPrice];
        NSString *maxPrice  =  (NSString *)[[CacheManager share].commonCache objectForKey:SelectMaxPrice];
        _minPriceField.text = minPrice;
        _maxPriceField.text = maxPrice;
        _selectModel.minPrice = minPrice;
        _selectModel.maxPrice = maxPrice;
        
 
    }
    return self;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(kIphoneWidth, 0, backViewWidth, kIphoneHeight)];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 8;
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"商品筛选";
        titleLab.textColor = kBlackTextColor;
        [_backView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(_backView.mas_top).offset(30);
            make.left.equalTo(_backView.mas_left).offset(15);
            make.height.equalTo(@25);
        }];
        
        [_backView addSubview:self.topCollectionView];
        [_topCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(titleLab.mas_bottom).offset(15);
            make.left.equalTo(_backView.mas_left);
            make.height.equalTo(@50);
        }];
        
        UILabel *priceLab = [[UILabel alloc] init];
        priceLab.text = @"价格区间";
        priceLab.textColor = kBlackTextColor;
        [_backView addSubview:priceLab];
        [priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(_topCollectionView.mas_bottom).offset(5);
            make.left.equalTo(_backView.mas_left).offset(15);
            make.height.equalTo(@25);
        }];
        
        UIView *centerLine = [[UIView alloc] init];
        centerLine.backgroundColor = kGrayLineColor;
        [_backView addSubview:centerLine];
        [centerLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(priceLab.mas_bottom).offset(35);
            make.width.equalTo(@15);
            make.height.equalTo(@1);
        }];
        
        
        
        _minPriceField = [[UITextField alloc] init];
        _minPriceField.backgroundColor = kBackGrayColor;
        [_minPriceField setRadius:4.f];
        _minPriceField.placeholder = @"最低价";
        _minPriceField.delegate = self;
        _minPriceField.textAlignment = NSTextAlignmentCenter;
        _minPriceField.font = [UIFont systemFontOfSize:14];
        _minPriceField.keyboardType = UIKeyboardTypeNumberPad;
        [_backView addSubview:_minPriceField];
        [_minPriceField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLab.mas_left);
            make.right.equalTo(centerLine.mas_left).offset(-10);
            make.centerY.equalTo(centerLine.mas_centerY);
            make.height.equalTo(@30);
        }];
        
        
        
        _maxPriceField = [[UITextField alloc] init];
        _maxPriceField.backgroundColor = kBackGrayColor;
        [_maxPriceField setRadius:4.f];
        _maxPriceField.placeholder = @"最高价";
        _maxPriceField.delegate = self;
        _maxPriceField.textAlignment = NSTextAlignmentCenter;
        _maxPriceField.font = [UIFont systemFontOfSize:14];
        _maxPriceField.keyboardType = UIKeyboardTypeNumberPad;
        [_backView addSubview:_maxPriceField];
        [_maxPriceField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_backView.mas_right).offset(-15);
            make.left.equalTo(centerLine.mas_right).offset(10);
            make.centerY.equalTo(centerLine.mas_centerY);
            make.height.equalTo(@30);
        }];
        
//        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [closeBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        [closeBtn addTarget:self action:@selector(dismissScreenView) forControlEvents:UIControlEventTouchUpInside];
//        [_backView addSubview:closeBtn];
//        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(_backView.mas_right).offset(-15);
//            make.centerY.equalTo(titleLab.mas_centerY);
//            make.width.equalTo(@24);
//            make.height.equalTo(@24);
//        }];
        
        UIView *firstLine = [[UIView alloc] init];
        firstLine.backgroundColor = kBackGrayColor;
        [_backView addSubview:firstLine];
        [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(_minPriceField.mas_bottom).offset(15);
            make.right.equalTo(_backView.mas_right);
            make.height.equalTo(@10);
        }];
        
        /*
        UIButton *hasGoodsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hasGoodsBtn setBackgroundImage:[UIImage imageNamed:@"selectBack_icon"] forState:UIControlStateNormal];
        [hasGoodsBtn setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateSelected];
        hasGoodsBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        hasGoodsBtn.selected = _isShowInStore;
        [hasGoodsBtn setTitleColor:kGrayTextColor forState:UIControlStateNormal];
        [hasGoodsBtn addTarget:self action:@selector(hasGoods:) forControlEvents:UIControlEventTouchUpInside];
        hasGoodsBtn.tag = 1200;
        [_backView addSubview:hasGoodsBtn];
        [hasGoodsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_backView.mas_left).offset(15);
            make.top.equalTo(firstLine.mas_bottom).offset(10);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        
        UILabel *hasGoodsLab = [[UILabel alloc] init];
        hasGoodsLab.text = @"仅看有货";
        hasGoodsLab.textColor = kGrayTextColor;
        hasGoodsLab.font = [UIFont systemFontOfSize:14];
        [_backView addSubview:hasGoodsLab];
        [hasGoodsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(hasGoodsBtn.mas_right).offset(5);
            make.top.equalTo(firstLine.mas_bottom).offset(10);
            make.width.equalTo(@80);
            make.height.equalTo(@20);
        }];*/
        
        
        UIView *secondLine = [[UIView alloc] init];
        secondLine.backgroundColor = kGrayLineColor;
        [_backView addSubview:secondLine];
        [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.bottom.equalTo(_backView.mas_bottom).offset(-45);
            make.right.equalTo(_backView.mas_right);
            make.height.equalTo(@0.5);
        }];
        
        UIView *thirdLine = [[UIView alloc] init];
        thirdLine.backgroundColor = kGrayLineColor;
        [_backView addSubview:thirdLine];
        [thirdLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.bottom.equalTo(_backView.mas_bottom);
            make.top.equalTo(secondLine.mas_bottom);
            make.width.equalTo(@1);
        }];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [resetBtn setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        [resetBtn addTarget:self action:@selector(resetSelect) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:resetBtn];
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_backView.mas_left);
            make.bottom.equalTo(_backView.mas_bottom);
            make.right.equalTo(thirdLine.mas_left);
            make.top.equalTo(secondLine.mas_bottom);
        }];
        
        UIButton *requireBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [requireBtn setTitle:@"确认" forState:UIControlStateNormal];
        [requireBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requireBtn setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(200, 50) andColor:kBackGreenColor] forState:UIControlStateNormal];
        [requireBtn addTarget:self action:@selector(completeSelect) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:requireBtn];
        [requireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thirdLine.mas_right);
            make.bottom.equalTo(_backView.mas_bottom);
            make.right.equalTo(_backView.mas_right);
            make.top.equalTo(secondLine.mas_bottom);
        }];
        
        [_backView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_backView.mas_centerX);
            make.top.equalTo(firstLine.mas_bottom).offset(15);
            make.bottom.equalTo(secondLine.mas_top);
            make.left.equalTo(_backView.mas_left);
        }];
    }
    return _backView;
}

/*
- (UIButton *)createSelectedBtnWithTitle:(NSString *)title andFrame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = kBackGrayColor;
    [button setRadius:5.f];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:kBlackTextColor forState:UIControlStateNormal];
    [button setTitleColor:kBackGreenColor forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"selected_icon"] forState:UIControlStateSelected];
//    button.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    
    button.selected = _isShowInStore;
    [button setTitleColor:kGrayTextColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(hasGoods:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 1200;
    [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.selected = !x.selected;
    }];
    return button;
}*/

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, backViewWidth, kIphoneHeight - 100) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"SelectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SelectCollectionViewCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PatientImageCollectHeaderView"];
    }
    return _collectionView;
}

- (UICollectionView *)topCollectionView {
    if (!_topCollectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _topCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, backViewWidth, 50) collectionViewLayout:layout];
        _topCollectionView.delegate = self;
        _topCollectionView.dataSource = self;
        _topCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_topCollectionView registerNib:[UINib nibWithNibName:@"SelectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SelectCollectionViewCell"];
    }
    return _topCollectionView;
}

- (void)hasGoods:(UIButton *)button {
    button.selected = !button.selected;
    _isShowInStore = button.selected;
    
}

- (void)dismissScreenView {
    [self removeFromSuperview];
}
#pragma mark - 重置

- (void)resetSelect {
    _isShowInStore = YES;
    _minPriceField.text = @"";
    _maxPriceField.text = @"";
    [_selectIndexArray removeAllObjects];
    
    [self clearCache];
    
    [self resetGoodsTypeModelDefaultData];
    
    
    [_topCollectionView reloadData];
    [_collectionView reloadData];
     self.screenComplete(_selectModel);
//    [self dismissScreenView];
}

- (void)resetGoodsTypeModelDefaultData {
    _selectModel.sortType = @"1";
    _selectModel.priceSort = @"";
//    _selectModel.searchName = @"";
    _selectModel.isHasGoods = @"true";
    _selectModel.minPrice = @"0";
    _selectModel.maxPrice = @"0";
    _selectModel.brandName = @"all";
    _selectModel.classificationId = @"0";
}

- (void)clearCache{
    [[CacheManager share].commonCache removeObjectForKey:SelectIndexArray];
    [[CacheManager share].commonCache removeObjectForKey:SelectMinPrice];
    [[CacheManager share].commonCache removeObjectForKey:SelectMaxPrice];
}


- (void)completeSelect {
    
    [_maxPriceField resignFirstResponder];
    [_minPriceField resignFirstResponder];
    
    if (IsStrEmpty(_selectModel.minPrice)) {
        _selectModel.minPrice = @"0";
    }
    if (IsStrEmpty(_selectModel.maxPrice)) {
        _selectModel.maxPrice = @"0";
    }
    _selectModel.isHasGoods = _isShowInStore ? @"YES":@"NO";
    
    NSMutableArray *brandArr = [NSMutableArray array];
    for (NSIndexPath *indexPath in _selectIndexArray) {
        if (indexPath.section == 1) {
            ClassifyListModel *model = [self.dataArray[indexPath.section] objectAtIndex:indexPath.row];
            if (model.twoClassifications.count > 0) {
                ClassifyListModel *subModel = [model.twoClassifications firstObject];
//                self.selectModel.searchName = model.name;
                self.selectModel.classificationId = [NSString stringWithFormat:@"%@", subModel.ID];
            } else {
                self.selectModel.classificationId = [NSString stringWithFormat:@"%@", model.ID];
            }
        } else {
            NSString *brand = [self.dataArray[indexPath.section] objectAtIndex:indexPath.row];
            [brandArr addObject:brand];
        }
    }
    
    if (brandArr.count > 0) {
        self.selectModel.brandName = [brandArr componentsJoinedByString:@","];
    } else {
        self.selectModel.brandName = @"all";
    }
    
    
    YWWeakSelf;
    self.screenComplete(weakSelf.selectModel);
    [self dismissScreenView];
}

#pragma mark CollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == _topCollectionView) {
        return 1;
    }
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _topCollectionView) {
        return 1;
    }
    if ([_dataArray[section] count] < 3) {
        return [_dataArray[section] count];
    }
    if (section == 0) {
        if (_isShowAllBrands) {
            return [_dataArray[section] count];
        } else {
            return 3;
        }
    } else if (section == 1) {
        if (_isShowAllClassfiy) {
            return [_dataArray[section] count];
        } else {
            return 3;
        }
    }
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (collectionView == _topCollectionView) {
        return CGSizeZero;
    }
    return CGSizeMake(300, 40);
}


//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return cellSize;
}


//定义每个Section /collectionView(指定区)的边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(5, 15, 15, 15);
    
}

//设定指定区内Cell的最小行距，也可以直接设置UICollectionViewFlowLayout的minimumLineSpacing属性
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

//..设定指定区内Cell的最小间距，也可以直接设置UICollectionViewFlowLayout的minimumInteritemSpacing属性
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _topCollectionView) {
        return nil;
    }
    UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PatientImageCollectHeaderView" forIndexPath:indexPath];
    
    for (UIView *view in reusableview.subviews) {
        [view removeFromSuperview];
    }
    
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(reusableview.frame), 0.5)];
//    line.backgroundColor = kGrayLineColor;
//    [reusableview addSubview:line];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 60, 20)];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textColor = kGrayTextColor;
    if (indexPath.section == 0) {
        titleLab.text = @"品牌";
    } else {
        titleLab.text = @"分类";
    }
    [reusableview addSubview:titleLab];
    
    UIButton *showAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showAllBtn.frame = CGRectMake(backViewWidth - 80, 5, 65, 30);
    showAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    if (_isShowAllBrands && indexPath.section == 0) {
        [showAllBtn setTitle:@"收起" forState:UIControlStateNormal];
    } else if (!_isShowAllBrands && indexPath.section == 0) {
        [showAllBtn setTitle:@"全部" forState:UIControlStateNormal];
    }
    if (_isShowAllClassfiy && indexPath.section == 1) {
        [showAllBtn setTitle:@"收起" forState:UIControlStateNormal];
    } else if(!_isShowAllClassfiy && indexPath.section == 1) {
        [showAllBtn setTitle:@"全部" forState:UIControlStateNormal];
    }
    
    [showAllBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    if (indexPath.section == 0) {
        [showAllBtn addTarget:self action:@selector(showAllBrands) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [showAllBtn addTarget:self action:@selector(showAllClassfiy) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [reusableview addSubview:showAllBtn];
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectCollectionViewCell" forIndexPath:indexPath];
    
    NSString *brandStr = nil;
    if (collectionView == _collectionView) {
        if (indexPath.section == 0) {
            brandStr = [self.dataArray[indexPath.section] objectAtIndex:indexPath.row];
        } else {
            ClassifyListModel *model = [self.dataArray[indexPath.section] objectAtIndex:indexPath.row];
            brandStr = model.name;
        }
        
        if ([_selectIndexArray containsObject:indexPath]) {
            [cell setBrandStr:brandStr isSelected:YES];
        } else {
            [cell setBrandStr:brandStr isSelected:NO];
        }
    } else {
        if (indexPath.row == 0) {
            brandStr = @"仅看有货";
            [cell setBrandStr:brandStr isSelected:_isShowInStore];
        } else {
            brandStr = @"促销";
            [cell setBrandStr:brandStr isSelected:_isShowSale];
        }
    }
    
    
    
    
    return cell;
}

- (void)showAllBrands {
    _isShowAllBrands = !_isShowAllBrands;
    [_collectionView reloadData];
}

- (void)showAllClassfiy {
    _isShowAllClassfiy = !_isShowAllClassfiy;
    [_collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_topCollectionView == collectionView) {
        if (indexPath.row == 0) {
            _isShowInStore = !_isShowInStore;
        } else {
            _isShowSale = !_isShowSale;
        }
    } else {
        if (_selectIndexArray.count == 0) {
            [_selectIndexArray addObject:indexPath];
        } else {
            
            
            if (indexPath.section == 1) {
                for (NSIndexPath *indexP in _selectIndexArray) {
                    if (indexP.section == 1) {
                        [_selectIndexArray removeObject:indexP];
                        break;
                    }
                }
                [_selectIndexArray addObject:indexPath];
            } else {
            
                BOOL hasIndex = [_selectIndexArray containsObject:indexPath];
                if (hasIndex) {
                    [_selectIndexArray removeObject:indexPath];
                } else {
                    [_selectIndexArray addObject:indexPath];
                }
            }
            
            
        }
    }
    
    
    [[CacheManager share].commonCache setObject:self.selectIndexArray forKey:SelectIndexArray];
    
    [UIView performWithoutAnimation:^{
        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }];
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

#pragma mark textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
//- (void)textFieldDidBeginEditing:(UITextField *)textField{

    if (textField == _minPriceField) {
        BOOL isRight = [self validateCarType:textField.text];
        if (isRight) {
              _selectModel.minPrice = textField.text;
        }else{
            _selectModel.minPrice = @"0";
        }
   
        [[CacheManager share].commonCache setObject:_selectModel.minPrice forKey:SelectMinPrice];
    } else if (textField == _maxPriceField) {
        BOOL isRight = [self validateCarType:textField.text];
        if (isRight) {
            _selectModel.maxPrice = textField.text;
        }else{
            _selectModel.maxPrice = @"0";
        }
        
        [[CacheManager share].commonCache setObject:_selectModel.maxPrice forKey:SelectMaxPrice];

    }
}



- (BOOL) validateCarType:(NSString *)CarType
{
    NSString *stringRegex = @"(([0]|(0[.]\\d{0,2}))|([1-9]\\d{0,8}(([.]\\d{0,2})?)))?";//一般格式 d{0,8} 控制位数
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",stringRegex];
    return [carTest evaluateWithObject:CarType];
}


@end
