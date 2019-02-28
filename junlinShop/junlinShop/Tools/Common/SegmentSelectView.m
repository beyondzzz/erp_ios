//
//  SegmentSelectView.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "SegmentSelectView.h"
#import "UIImage+YWExtension.h"
#import "UIButton+YWExtension.h"

#define buyWidth (CGRectGetWidth(frame) / 4)
@interface SegmentSelectView ()

@property (nonatomic) SegmentViewType type;

@end

@implementation SegmentSelectView

- (instancetype)initWithFrame:(CGRect)frame andTitleArray:(NSArray *)titleArray andImageNameArray:(NSArray *)imageArray byType:(SegmentViewType)segmentType {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kBackViewColor;
        _type = segmentType;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        lineView.tag = 1250;
        lineView.backgroundColor = kBackGrayColor;
        [self addSubview:lineView];
        
        UIView *lineView02 = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        lineView02.tag = 1260;
        lineView02.backgroundColor = kBackGrayColor;
        [self addSubview:lineView02];
        
        CGFloat btnWidth = (CGRectGetWidth(frame) - 10) / titleArray.count;
        for (int i = 0; i < titleArray.count; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 1000 + i;
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:kGrayTextColor forState:UIControlStateNormal];
            [button setTitleColor:kBackGreenColor forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:16.f];
            button.frame = CGRectMake(btnWidth * i + 5, 0, btnWidth, CGRectGetHeight(frame));
            [button addTarget:self action:@selector(clickSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            [button setAdjustsImageWhenHighlighted:NO];
            
            if (segmentType == SegmentViewTypeClassfiy) {
//                [button setImage:[UIImage imageNamed:@"segment_dwon_Jiantou"] forState:UIControlStateSelected];
//                [button setImage:[UIImage imageNamed:@"segment_up_Jiantou"] forState:UIControlStateNormal];
                
                [button setImage:[UIImage createImageWithSize:CGSizeMake(24, 24) andColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [button setImage:[UIImage createImageWithSize:CGSizeMake(24, 24) andColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
                
                [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4.f];
            }
            
            if (segmentType == SegmentViewTypeGoodsList) {
                /*
                if (i == 0 || i == 3) {
                    [button setImage:[UIImage imageNamed:@"jiantou_down"] forState:UIControlStateSelected];
                    [button setImage:[UIImage createImageWithSize:CGSizeMake(24, 24) andColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                    [button setImage:[UIImage createImageWithSize:CGSizeMake(24, 24) andColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
                    
                    [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4.f];
                }
                */
            }
            
            if (segmentType == SegmentViewTypeTopImage) {
                [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
                [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10.f];
            }
            
            if (segmentType == SegmentViewTypeBuy) {
                
                if (i < 2) {
                    button.frame = CGRectMake((buyWidth - 25) * i, 0, buyWidth - 25, CGRectGetHeight(frame));
                    button.titleLabel.font = [UIFont systemFontOfSize:14.f];
                    [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:5.f];
                    
                } else {
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
                if (i == 2) {
                    button.frame = CGRectMake(buyWidth * 2 - 50, 0, buyWidth + 25, CGRectGetHeight(frame));
                    [button setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(btnWidth, CGRectGetHeight(frame)) andColor:kBackGreenColor] forState:UIControlStateNormal];
                }
                if (i == 3) {
                    button.frame = CGRectMake(buyWidth * 3 - 25, 0, buyWidth + 25, CGRectGetHeight(frame));
                    [button setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(btnWidth, CGRectGetHeight(frame)) andColor:kBackYellowColor] forState:UIControlStateNormal];
                }
            }
            
            if (segmentType == SegmentViewTypeBottonLine) {
                if (i == 0) {
                    button.selected = YES;
                }
            }
            
        }
        
        switch (segmentType) {
            case SegmentViewTypeClassfiy: {
                
            }
                break;
            case SegmentViewTypeBuy: {
                
            }
                break;
            case SegmentViewTypeBottonLine: {
                CGFloat width = [ASHString LabWidthWithString:titleArray[0] font:[UIFont systemFontOfSize:16.f] andRectWithSize:CGSizeMake(kIphoneWidth / 2, 20)] + 6;
                UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake((btnWidth - width) / 2 + 5, CGRectGetHeight(frame) - 2, width, 3)];
                [bottomView setRadius:1.f];
                bottomView.tag = 1200;
                bottomView.backgroundColor = kBackGreenColor;
                [self addSubview:bottomView];
                }
                break;
            case SegmentViewTypeTopImage: {
                    
                }
                break;
            default:
                break;
        }
        
    }
    
    YWWeakSelf;
    self.changeButtonTitle = ^(NSInteger index, NSString *title) {
        UIButton *button = [weakSelf viewWithTag:index + 1000];
        if (button) {
            [button setTitle:title forState:UIControlStateNormal];
        }
    };
    
    return self;
}

- (void)clickSelectBtn:(UIButton *)button {
    [self changeToSelectBtn:button];
    
    UIButton *btn = [self viewWithTag:1002];
    if (btn) {
        [btn setImage:nil forState:UIControlStateNormal];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickButton:AtIndex:)]) {
        [self.delegate clickButton:button AtIndex:button.tag - 1000];
    }
}

- (void)changeToSelectBtn:(UIButton *)button {
    if (_type == SegmentViewTypeBottonLine || _type == SegmentViewTypeClassfiy) {
        
        
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
            }
        }
        button.selected = YES;
        
        UIView *bottomView = [self viewWithTag:1200];
        if (bottomView) {
            CGFloat width = [ASHString LabWidthWithString:button.currentTitle font:button.titleLabel.font andRectWithSize:CGSizeMake(kIphoneWidth / 2, 20)] + 6;
            [UIView animateWithDuration:0.5 animations:^{
                bottomView.frame = CGRectMake(CGRectGetMidX(button.frame) - width / 2, CGRectGetHeight(button.frame) - 3, width, 3);
            }];
        }
    }
    
    if (_type == SegmentViewTypeGoodsList) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]] && view != button) {
                UIButton *btn = (UIButton *)view;
                btn.selected = NO;
            }
        }
        button.selected = !button.selected;
        
        NSArray *listArray = @[@"综合", @"销量", @"价格", @"品牌"];
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                if (btn.selected == NO) {
                    NSInteger i = btn.tag - 1000;
                    [btn setTitle:listArray[i] forState:UIControlStateNormal];
                }
                
            }
        }
    }
}

- (void)srcollToSelectedBtnAtIndex:(NSInteger)index {
    UIButton *button = [self viewWithTag:index + 1000];
    if (button) {
        [self changeToSelectBtn:button];
    }
}

- (void)dealloc {
    [YWNoteCenter removeObserver:self];
}

 

@end
