//
//  UserNameSetViewController.h
//  junlinShop
//
//  Created by jianxuan on 2017/11/29.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface UserNameSetViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@property (nonatomic, copy) void (^completeChangeUserName)(NSString *userName);

@end
