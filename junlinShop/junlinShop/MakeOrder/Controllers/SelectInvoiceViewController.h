//
//  SelectInvoiceViewController.h
//  junlinShop
//
//  Created by jianxuan on 2017/12/11.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectInvoiceViewController : BaseViewController

@property (nonatomic, copy) void (^selectInvoice)(BOOL isNormal, BOOL isGeren, BOOL isGoods, NSDictionary *invoiceDic);

@end
