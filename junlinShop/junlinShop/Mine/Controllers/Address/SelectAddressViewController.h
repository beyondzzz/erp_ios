//
//  SelectAddressViewController.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectAddressViewController : BaseViewController

@property (nonatomic, copy) void (^completeSelectedAddress)(NSNumber *addressID, NSString *addressStr);

@end
