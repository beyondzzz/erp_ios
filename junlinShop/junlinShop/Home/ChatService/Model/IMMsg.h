//
//  IMMsg.h
//  ChatCellDemo
//
//  Created by 幻想无极（谭启宏） on 16/9/5.
//  Copyright © 2016年 幻想无极（谭启宏）. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, IMMsgFrom)
{
    IMMsgFromOther = 0,        //其他
    IMMsgFromLocalSelf = 1,    //本地
    IMMsgFromRemoteSelf = 2,   //远程
};
typedef NS_ENUM(NSInteger, IMMsgType)
{
    IMMsgTypeText = 0,
    IMMsgTypeAudio,
    IMMsgTypePic,
    IMMsgTypeFile,
    IMMsgTypeFriendCenter,
    IMMsgTypeVideo,
    IMMsgTypeNews,
    IMMsgTypePost,
    IMMsgTypeMail,
    IMMsgTypeNotice,
    IMMsgTypeBusiness,
    IMMsgTypeLocatioin,
    IMMsgTypeGift,
    IMMsgTypeEmotion,
};
/**消息模型－－－－－－*/
@interface IMMsg : NSObject

@property (nonatomic,assign) IMMsgFrom fromType; //消息发送方
@property (nonatomic,strong) NSString *msgBody; //消息body
@property (nonatomic,assign) IMMsgType msgType;
@end
