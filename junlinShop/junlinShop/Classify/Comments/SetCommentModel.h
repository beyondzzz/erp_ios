//
//  SetCommentModel.h
//  junlinShop
//
//  Created by jianxuan on 2018/1/29.
//  Copyright © 2018年 叶旺. All rights reserved.
//

#import "BaseModel.h"

@interface SetCommentModel : BaseModel

//@property (nonatomic, strong) NSString *evaluationImg;
@property (nonatomic, strong) NSNumber *orderDetailId;
@property (nonatomic, strong) NSString *evaluationContent;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray *imageUrlArr;
@property (nonatomic, strong) NSString *goodsImgUrl;

@end
