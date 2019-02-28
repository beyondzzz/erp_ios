//
//  YWCountdownView.m
//  meirongApp
//
//  Created by 叶旺 on 2017/12/20.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "YWCountdownView.h"

@interface YWCountdownView ()
{
    dispatch_source_t _timer;
}

@property (weak, nonatomic) IBOutlet UILabel *hourLab;
@property (weak, nonatomic) IBOutlet UILabel *minuteLab;
@property (weak, nonatomic) IBOutlet UILabel *secondLab;

@end

@implementation YWCountdownView

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    [super awakeFromNib];
}

- (void)setToEndTime:(NSTimeInterval)time {
//    NSDate *startDate = [NSDate date];
//    NSTimeInterval timeInterval =[date timeIntervalSinceDate:startDate];
    if (time > 0) {
        [self countdownWithTimeInterval:time];
    }
}

- (void)setStartTimeWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSInteger timeInterval = hour * 3600 + minute * 60 + second;
    [self countdownWithTimeInterval:timeInterval];
}

- (void)countdownWithTimeInterval:(NSInteger)timeInterval {
    
    if (_timer == nil) {
        __block NSInteger timeout = timeInterval; //倒计时时间
        
        if (timeout!=0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout <=0){ //倒计时结束，关闭
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.hourLab.text = @"0天";
                        self.hourLab.text = @"00";
                        self.minuteLab.text = @"00";
                        self.secondLab.text = @"00";
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(countdownViewTimeCountToZero:)]) {
                            [self.delegate countdownViewTimeCountToZero:self];
                        }
                    });
                }else{
                    NSInteger days = (NSInteger)(timeout/(3600*24));
                    NSInteger hours = (NSInteger)((timeout-days*24*3600)/3600);
                    NSInteger minute = (NSInteger)(timeout-days*24*3600-hours*3600)/60;
                    NSInteger second = timeout-days*24*3600-hours*3600-minute*60;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.hourLab.text = [NSString stringWithFormat:@"%02ld",hours];
                        self.minuteLab.text = [NSString stringWithFormat:@"%02ld",minute];
                        self.secondLab.text = [NSString stringWithFormat:@"%02ld",second];
                        
                    });
                    timeout--;
                }
            });
            dispatch_resume(_timer);
        }
    }
}

- (void)setTextColor:(UIColor *)textColor {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = textColor;
        }
    }
}

- (void)drawRect:(CGRect)rect {
    
}

- (void)dealloc {

}

@end
