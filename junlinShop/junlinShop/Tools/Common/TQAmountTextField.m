//
//  TQAmountTextField.m
//  TQMall
//
//  Created by Coco on 15/5/6.
//  Copyright (c) 2015年 Hangzhou Xuanchao Technology Co. Ltd. All rights reserved.
//

#import "TQAmountTextField.h"
#define kBtnWidth ((self.frame.size.width - 36) / 2)
#define kBtnHeight self.frame.size.height

@implementation TQAmountTextField

+ (instancetype)defaultView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        if (!_stepLength) {
            _stepLength = 1;
        }
        if (!_buyMinNumber) {
            _buyMinNumber = 1;
        }
        
        self.TQTextFiled.rightViewMode = UITextFieldViewModeAlways;
        self.TQTextFiled.leftViewMode = UITextFieldViewModeAlways;
        self.TQTextFiled.rightView = self.addButton;
        self.TQTextFiled.leftView = self.subButton;
        self.TQTextFiled.returnKeyType = UIReturnKeyDone;
        self.TQTextFiled.font = [UIFont systemFontOfSize:14];
        self.TQTextFiled.textColor = [UIColor blackColor];
        self.TQTextFiled.textAlignment = NSTextAlignmentCenter;
        self.TQTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.TQTextFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
        self.layer.borderWidth = 1;
        self.layer.borderColor = kRGBColor(221, 221, 221, 1).CGColor;
        self.TQTextFiled.delegate = self;
    }
    return self;
}

- (UIButton *)subButton
{
    if (_subButton == nil) {
        _subButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _subButton.frame = CGRectMake(0, 0, kBtnWidth, kBtnHeight);
        [_subButton setTitle:@"-" forState:UIControlStateNormal];
        _subButton.titleLabel.font = [UIFont systemFontOfSize:21];
        [_subButton setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        [_subButton addTarget:self action:@selector(subButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_subButton];
        
        _TQTextFiled = [UITextField new];
        _TQTextFiled.frame = CGRectMake(kBtnWidth, 0, 36, kBtnHeight);
        _TQTextFiled.text = [NSString stringWithFormat:@"%ld",_buyMinNumber];
        [_TQTextFiled setBorder:kGrayLineColor width:1 radius:0];
        [self addSubview:_TQTextFiled];
        
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(CGRectGetWidth(self.frame) - kBtnWidth, 0, kBtnWidth, kBtnHeight);
        [_addButton setTitle:@"+" forState:UIControlStateNormal];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_addButton setTitleColor:kBlackTextColor forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(plusButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_addButton];
        
    }
    return _subButton;
}
- (void)setIncreaseImageName:(NSString *)increaseImageName{

    [_subButton setBackgroundImage:[UIImage imageNamed:increaseImageName] forState:UIControlStateNormal];

}
- (void)setDecreaseImageName:(NSString *)decreaseImageName{
    
    [_addButton setBackgroundImage:[UIImage imageNamed:decreaseImageName] forState:UIControlStateNormal];

}

- (void)setBuyMinNumber:(NSInteger)buyMinNumber {
    _buyMinNumber = buyMinNumber;
    _TQTextFiled.text = [NSString stringWithFormat:@"%ld", buyMinNumber];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    NSString *newString;
    if ([string isEqualToString:filtered] && newLength <= 4) {
        newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    else{
        newString = textField.text;
    }
    if ([_amountDelegate respondsToSelector:@selector(amountTextField:FinishInputWithInteger:)]) {
        [_amountDelegate amountTextField:self FinishInputWithInteger:[newString integerValue]];
    }
    if (_changeNumber) {
        _changeNumber([newString integerValue]);
    }
    
    return [string isEqualToString:filtered] && newLength <= 4;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text integerValue] < 1) {
        textField.text = @"1";
    }
    
    if ([_amountDelegate respondsToSelector:@selector(amountTextField:FinishInputWithInteger:)]) {
        [_amountDelegate amountTextField:self FinishInputWithInteger:[self.TQTextFiled.text integerValue]];
    }
    if (_changeNumber) {
        _changeNumber([textField.text integerValue]);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text integerValue] < 1) {
        textField.text = @"0";
        return NO;
    }
    
    [textField resignFirstResponder];
    if ([_amountDelegate respondsToSelector:@selector(amountTextField:FinishInputWithInteger:)]) {
        [_amountDelegate amountTextField:self FinishInputWithInteger:[self.TQTextFiled.text integerValue]];
    }
    
    if (_changeNumber) {
        _changeNumber([textField.text integerValue]);
    }
    
    return YES;
}

- (void)subButtonClick:(UIButton *)btn
{
    [self resignFirstResponder];
    if (self.TQTextFiled.text.integerValue > 0&&self.TQTextFiled.text.integerValue>_buyMinNumber) {
        self.TQTextFiled.text = [NSString stringWithFormat:@"%li",self.TQTextFiled.text.integerValue - _stepLength];
    }
    else{
//        self.text = @"0";
        self.TQTextFiled.text = [NSString stringWithFormat:@"%ld",_buyMinNumber];
    }
    if ([_amountDelegate respondsToSelector:@selector(amountTextField:FinishInputWithInteger:)]) {
        [_amountDelegate amountTextField:self FinishInputWithInteger:[self.TQTextFiled.text integerValue]];
    }
    
    NSInteger number = [self.TQTextFiled.text integerValue];
    if (_changeNumber) {
        _changeNumber(number);
    }
}

- (void)plusButtonClick:(UIButton *)btn
{
    [self resignFirstResponder];
    if (self.TQTextFiled.text.integerValue > 99) {
        self.TQTextFiled.text = [NSString stringWithFormat:@"99"];
    }
    else{
        self.TQTextFiled.text = [NSString stringWithFormat:@"%li",self.TQTextFiled.text.integerValue + _stepLength];
    }
    if ([_amountDelegate respondsToSelector:@selector(amountTextField:FinishInputWithInteger:)]) {
        [_amountDelegate amountTextField:self FinishInputWithInteger:[self.TQTextFiled.text integerValue]];
    }
    NSInteger number = [self.TQTextFiled.text integerValue];
    if (_changeNumber) {
        _changeNumber(number);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.TQTextFiled.rightViewMode = UITextFieldViewModeAlways;
    self.TQTextFiled.leftViewMode = UITextFieldViewModeAlways;
    self.TQTextFiled.rightView = self.addButton;
    self.TQTextFiled.leftView = self.subButton;
    self.TQTextFiled.returnKeyType = UIReturnKeyDone;
    self.TQTextFiled.font = [UIFont systemFontOfSize:14];
    self.TQTextFiled.textColor = [UIColor blackColor];
    self.TQTextFiled.textAlignment = NSTextAlignmentCenter;
    self.TQTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.TQTextFiled.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 3;
    self.layer.borderColor = kRGBColor(221, 221, 221, 1).CGColor;
    self.TQTextFiled.text = @"0";
    self.TQTextFiled.delegate = self;
}



@end
