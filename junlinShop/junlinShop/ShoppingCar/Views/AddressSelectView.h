//
//  AddressSelectView.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/23.
//  Copyright © 2017年 叶旺. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompleteSelect)(NSString *address);
@interface AddressSelectView : UIView

- (instancetype)initAddressArray:(NSArray *)addressArray complete:(CompleteSelect)complete;

@end
