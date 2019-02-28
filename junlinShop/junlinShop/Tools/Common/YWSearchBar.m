//
//  YWSearchBar.m
//  junlinShop
//
//  Created by jianxuan on 2017/11/27.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "YWSearchBar.h"

@implementation YWSearchBar

- (instancetype)initWithFrame:(CGRect)frame andStyle:(YWSearchBarStyle)style{
    if (self = [super initWithFrame:frame]) {
        self.placeholder = @"请输入商品名称";
        
        UIColor *backColor = [UIColor whiteColor];
        UIColor *borderColor = [UIColor whiteColor];
        if (style == YWSearchBarStyleWhiteColor) {
            
        } else if (style == YWSearchBarStyleGrayColor) {
            backColor = kBackGrayColor;
            borderColor = kGrayLineColor;
        }
        self.layer.borderColor = borderColor.CGColor;
        [self setBackgroundImage:[UIImage createImageWithSize:CGSizeMake(frame.size.width, frame.size.height) andColor:backColor]];
        self.backgroundColor = backColor;
        
        self.layer.cornerRadius = frame.size.height/2.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        
        UITextField *searchField = [self valueForKey:@"searchField"];
        
        if (searchField) {
            [searchField setBackgroundColor:backColor];
            searchField.font = [UIFont systemFontOfSize:15];
            UIImageView *searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            searchImageView.image = [UIImage imageNamed:@"searchBar_icon"];
            searchField.leftView = searchImageView;
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
