//
//  CircleImageView.m
//  mhd2
//
//  Created by peter.ye on 16/9/24.
//  Copyright © 2016年 peter.ye. All rights reserved.
//

#import "CircleImageView.h"

@interface CircleImageView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) CGFloat totalScale;
@property (nonatomic) CGPoint normalPosition;
@property (nonatomic, strong) NSArray *descurArray;

@end

@implementation CircleImageView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        

        
        _totalScale = 1.f;
    }
    return self;
}

- (void)setImageArray:(NSArray *)imageArr andIndex:(NSInteger)index descuribtionArray:(NSArray *)desArr {
    _descurArray = desArr;
    [self setImageArray:imageArr andIndex:index];
}

- (void)setImageArray:(NSArray *)imageArr andIndex:(NSInteger)index {

    for (int i = 0; i < imageArr.count + 1; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kIphoneWidth * i, 0, kIphoneWidth, kIphoneHeight)];
        
        if (i == 0) {
            if ([imageArr[imageArr.count - 1] isKindOfClass:[UIImage class]]) {
                imageView.image = imageArr[imageArr.count - 1];
            } else {
                [self showWebImageWithUrl:imageArr[imageArr.count - 1] andImageView:imageView];
            }
        } else {
            if ([imageArr[i - 1] isKindOfClass:[UIImage class]]) {
                imageView.image = imageArr[i - 1];
            } else {
                [self showWebImageWithUrl:imageArr[i - 1] andImageView:imageView];
            }
        }
        imageView.tag = 1200 + i;
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor blackColor];
        
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake((imageArr.count + 1) * kIphoneWidth, kIphoneHeight);
    _scrollView.contentOffset = CGPointMake(kIphoneWidth * (index + 1), 0);
    if (imageArr.count == 1) {
        _scrollView.scrollEnabled = NO;
    }
    
//    self.countLab.text = [NSString stringWithFormat:@"%ld/%ld", index + 1, imageArr.count];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCircleImageView:)];
    [_scrollView addGestureRecognizer:tapGesture];
    
    
    [YWWindow addSubview:self];
}

- (void)showWebImageWithUrl:(NSString *)urlStr andImageView:(UIImageView *)imageView {
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(kIphoneWidth / 2 - 50, kIphoneHeight / 2 - 50, 100, 100)];
    activityView.color = kRGBColor(151, 151, 151, 1);
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [imageView addSubview: activityView];
    [activityView startAnimating];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"%@--%@",image,imageURL );
    }];
    
//    [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage new] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        [activityView stopAnimating];
//        [activityView removeFromSuperview];
//    }];
}

- (void)dismissCircleImageView:(UIGestureRecognizer *)gesture {
//    _backView.hidden = !_backView.hidden;
//    if (_descurArray.count > 0) {
//        _desLab.hidden = !_desLab.hidden;
//    }
    [self doBack:nil];
}

- (void)doBack:(UIButton *)button {
    [self removeFromSuperview];
}



 

@end

