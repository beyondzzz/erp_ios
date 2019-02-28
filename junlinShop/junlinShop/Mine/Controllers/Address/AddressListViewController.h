//
//  AddressListViewController.h
//  meirongApp
//
//  Created by jianxuan on 2017/12/1.
//  Copyright © 2017年 jianxuan. All rights reserved.
//

#import "BaseViewController.h"
#import "AddressModel.h"

@interface AddressListViewController : BaseViewController

@property (nonatomic) BOOL isSelectAddress;
@property (nonatomic, copy) void (^selectedAddress)(AddressModel *model);

@end
