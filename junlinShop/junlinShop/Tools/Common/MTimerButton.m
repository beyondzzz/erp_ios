//
//  MTimerButton.m
//  OTemplate
//
//  Created by jun.wang on 15/8/6.
//  Copyright (c) 2015年 Ashermed. All rights reserved.
//

#import "MTimerButton.h"

@interface MTimerButton ()
{
    dispatch_source_t _timer;
}
@end

@implementation MTimerButton

#pragma mark 数字倒计时
- (void)countDownWithNum:(NSInteger)num
{
    __block int timeout = (int)(num - 1);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示 根据自己需求设置
                [self setTitle:@"重新发送" forState:UIControlStateNormal];
                self.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = timeout % num;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateNormal];
                self.userInteractionEnabled = NO;
            });
            
            timeout--;
        }
    });
    
    dispatch_resume(_timer);
}

#pragma mark 取消
- (void)countDownCancel
{
    if (_timer) {
        
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

@end
