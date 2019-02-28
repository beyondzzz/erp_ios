//
//  MoyouSmallIconText.m
//  moyouAPP
//
//  Created by 幻想无极（谭启宏） on 16/8/19.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import "MoyouSmallIconText.h"
#import "UIView+Extension.h"

@interface MoyouSmallIconText ()

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *label;


//@property (nonatomic,assign)CGFloat maxWith;
//@property (nonatomic,assign)CGFloat maxHeight;

@property (nonatomic,assign)CGSize textSize;
@property (nonatomic,assign)BOOL isLeft;

@end

@implementation MoyouSmallIconText

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.maxWith = frame.size.width;
        self.maxHeight = frame.size.height;
        self.edge = UIEdgeInsetsMake(5, 5, 5, 5);
        self.font = 14;
        self.iconTextPadding = 5;
        self.leftPadding = 5;
        self.rightPadding = 5;
        [self common];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.maxWith = 100;
        self.maxHeight = 100;
        self.edge = UIEdgeInsetsMake(5, 5, 5, 5);
        self.font = 14;
        self.iconTextPadding = 5;
        self.leftPadding = 5;
        self.rightPadding = 5;
        [self common];
    }
    return self;
}

- (void)common {
    self.imageView = [UIImageView new];
    self.label = [UILabel new];
    self.label.font = [UIFont systemFontOfSize:self.font];
    self.label.textColor = [UIColor redColor];
    [self addSubview:self.imageView];
    [self addSubview:self.label];
}

- (void)setFont:(CGFloat)font {
    _font = font;
    self.label.font = [UIFont systemFontOfSize:font];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.label.textColor = color;
}

- (void)setleftImage:(UIImage *)image text:(NSString *)text {
    self.isLeft = YES;
    self.imageView.image = image;
    self.label.text = text;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.maxWith, self.maxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font]} context:nil];
    self.textSize = rect.size;
    self.imageView.frame = CGRectMake(self.edge.left+self.leftPadding,
                                      self.edge.top,
                                      self.height - self.edge.left - self.edge.right,
                                      self.height - self.edge.top - self.edge.bottom);
    self.label.frame = CGRectMake(self.imageView.maxX+self.edge.right+self.iconTextPadding, 0,  self.textSize.width, self.height);

    self.frame = CGRectMake(self.x, self.y, self.label.maxX+self.rightPadding, self.height);
}

- (void)setRightImage:(UIImage *)image text:(NSString *)text {
    self.isLeft = NO;
    self.imageView.image = image;
    self.label.text = text;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.maxWith, self.maxHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font]} context:nil];
    self.textSize = rect.size;
    self.label.frame = CGRectMake(self.leftPadding, 0,  self.textSize.width+self.iconTextPadding, self.height);
    self.imageView.frame = CGRectMake(self.edge.left+self.label.maxX,
                                      self.edge.top,
                                      self.height - self.edge.left - self.edge.right,
                                      self.height - self.edge.top - self.edge.bottom);

    
    self.frame = CGRectMake(self.x, self.y, self.imageView.maxX+self.edge.right+self.rightPadding, self.height);
}

//为自动布局而写的
- (void)layoutSubviews {
    if (self.isLeft) {
        self.imageView.frame = CGRectMake(self.edge.left+self.leftPadding,
                                          self.edge.top,
                                          self.height - self.edge.left - self.edge.right,
                                          self.height - self.edge.top - self.edge.bottom);
        self.label.frame = CGRectMake(self.imageView.maxX+self.edge.right+self.iconTextPadding, 0,  self.textSize.width, self.height);

    }else {
        self.label.frame = CGRectMake(self.leftPadding, 0,  self.textSize.width+self.iconTextPadding, self.height);
        self.imageView.frame = CGRectMake(self.edge.left+self.label.maxX,
                                          self.edge.top,
                                          self.height - self.edge.left - self.edge.right,
                                          self.height - self.edge.top - self.edge.bottom);
    }
 
}

@end
