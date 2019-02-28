//
//  ShowNoticeStringController.m
//  junlinShop
//
//  Created by 叶旺 on 2018/5/21.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "ShowNoticeStringController.h"

@interface ShowNoticeStringController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ShowNoticeStringController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textView.editable = NO;
    
    NSString *noticeStr = nil;
    switch (_noticeType) {
        case YWNoticeStringNormal: {
            
        }
            break;
        case YWNoticeStringAptitude: {
            self.navigationItem.title = @"增票资质确认书";
            self.titleLab.text = @"申请开具增值税专用发票确认书";
            noticeStr = @"       根据国家税法及发票管理相关规定，任何单位和个人不得要求他人为自己开具与实际经营业务情况不符的增值税专用发票【包括并不限于（1）在没有货物采购或者没有接受应税劳务的情况下要求他人为自己开具增值税专用发票；（2）虽有货物采购或者接受应税劳务但要求他人为自己开具数量或金额与实际情况不符的增值税专用发票】，否则属于“虚开增值税专用发票”。\n       我已充分了解上述各项相关国家税法和发票管理规定，并确认仅就我司实际购买商品或服务索取发票。如我司未按国家相关规定申请开具或使用增值税专用发票，由我司自行承担相应法律后果。";
        }
            break;
        default:
            break;
    }
    
    NSMutableAttributedString *tipsString = [[NSMutableAttributedString alloc] initWithString:noticeStr];
    self.textView.attributedText = tipsString;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
