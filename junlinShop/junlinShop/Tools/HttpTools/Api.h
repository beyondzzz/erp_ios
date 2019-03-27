//
//  Api.h
//  junlinShop
//
//  Created by 叶旺 on 2017/11/21.
//  Copyright © 2016年 叶旺. All rights reserved.
//

#ifndef Api_h
#define Api_h

//0:测试 1:正式
#define IsRelease 0
//2.自动更新 0:fir  1. apple store
#define AutoUpdate 0

#if IsRelease
#define YWBaseURL            @""
#define YWHWebURL             @""
#else
#define YWBaseURL            @"http://39.105.115.214:8080/JLMIS/"
#define YWWebURL             @""
#endif

#define AppleStoreID @"1391668256"
#define AppUpdateURL            [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", AppleStoreID]

#define kAppendUrl(url)           [YWBaseURL stringByAppendingString:url]
#define kAppendWebUrl(url)           [YWWebURL stringByAppendingString:url]

static NSString* const YWLoginString = @"user/login"; // 登录
static NSString* const YWMessageCodeString = @"user/MessageCode"; // 登录
static NSString* const YWBindPhoneString = @"user/bindPhone"; //绑定手机号

//地址相关
static NSString* const YWAddressListString = @"shippingAddress/getShippingAddressByUserId";
static NSString* const YWAddressAddString = @"shippingAddress/insertShippingAddress";
static NSString* const YWAddressUpdateString = @"shippingAddress/ updateShippingAddressById";
static NSString* const YWAddressDeleteString = @"shippingAddress/ deleteShippingAddressById";
static NSString* const YWAddressDefaultString = @"shippingAddress/setPretermissionShippingAddressById";
static NSString* const YWGetPostageString = @"freeDelivery/getPostage";

//商品相关
static NSString* const YWClassifyString = @"classification/getClassificationMsg"; //商品分类
static NSString* const YWGoodsListString = @"goodsInformation/getGoodsList"; //商品列表
static NSString* const YWAmeliorateListString = @"goodsInformation/getGoodsList_Ameliorate"; //新品上架商品列表
static NSString* const YWGoodsBrandString = @"goodsInformation/selectBrand";
static NSString* const YWGoodsDetailString = @"goodsInformation/getGoodsDetailMsgByGoodsId"; //商品详情

static NSString* const YWHotSearchWordString = @"goodsInformation/selectHotSearchWord"; //热搜

//订单相关
static NSString* const YWOrderListString = @"order/getOrderList"; //列表
static NSString* const YWOrderDetailString = @"order/ getOrderDetail"; //详情
static NSString* const YWOrderStateDetailString = @"order/getOrderStateDetail"; //追踪
static NSString* const YWOrderInsertString = @"order/insertOrder"; //提交
static NSString* const YWOrderInventoryString = @"order/decisionInventory"; //库存
static NSString* const YWOrderCancleString = @"order/cancleOrder"; //订单操作


//购物车相关
static NSString* const YWShopCarListString = @"shoppingCart/getShoppingCart"; //列表
static NSString* const YWAddShopCarString = @"shoppingCart/insertShoppingCart"; //添加
static NSString* const YWDeleteShopCarString = @"shoppingCart/deleteShoppingCartById"; //删除
static NSString* const YWDeleteShopCarGoodsString = @"shoppingCart/deleteBatchShoppingCartById"; //删除
static NSString* const YWEditShopCarString = @"shoppingCart/editShoppingCartGoodsById";
static NSString* const YWCopyOrderShopCarString = @"shoppingCart/copyorderShoppingCart"; //重复添加

//评价相关
static NSString* const YWCommentListString = @"goodsEvaluation/getEvaluationByUserId"; //
static NSString* const YWCommentDetailString = @"goodsEvaluation/getEvaluationDetailByUserIdAndId"; //
static NSString* const YWCommentSaveString = @"goodsEvaluation/insertGoodsEvaluation"; //
static NSString* const YWOrderCommentString = @"goodsEvaluation/getEvaluationDetailByUserIdAndOrderId";
static NSString* const YWOrderNoCommentString = @"order/getOrderDetailNoEvaluation";


//上传
static NSString* const YWFileUploadString = @"FileUpload/imgUpload"; //


//发票相关
static NSString* const YWGetInvoiceAptitudeString = @"invoice/getVatInvoiceAptitudeByUserId"; //增票信息
static NSString* const YWGetInvoiceUnitString = @"invoice/getInvoiceUnitByUserId"; //单位信息列表
static NSString* const YWGetAllInvoiceUnitString = @"invoice/getInvoiceUnitAndVatInvoiceAptitudeByUserId"; //单位信息+增票信息
static NSString* const YWCheckInvoiceAptitudeString = @"invoice/commitVatInvoiceAptitudeToCheck"; //增票审核
static NSString* const YWDeleteInvoiceAptitudeString = @"invoice/deleteVatInvoiceAptitudeById"; //增票删除
static NSString* const YWUpdateInvoiceUnitString = @"invoice/updateInvoiceUnitById"; //普票修改
static NSString* const YWUpdateInvoiceAptitudeString = @"invoice/updateVatInvoiceAptitudeById"; //增票修改
static NSString* const YWAddInvoiceUnitString = @"invoice/addInvoiceUnit"; //添加普票
static NSString* const YWDeleteInvoiceUnitString = @"invoice/ deleteInvoiceUnitById"; //删除普票

//活动优惠券相关
static NSString* const YWGetActivitysAndCouponsString = @"activityInformation/getActivitysAndCouponsByGoodsMsg"; //可使用的活动优惠券列表
static NSString* const YWCanGetCouponsString = @"couponInformation/getAllAvailableCoupon"; //可领取优惠券列表
static NSString* const YWGetCouponString = @"couponInformation/userGetCoupon"; //领取优惠券
static NSString* const YWCouponsListString = @"couponInformation/getCouponInfoByUserId"; //已有优惠券列表
static NSString* const YWCouponGoodsString = @"couponInformation/getMsgByCouponId"; //优惠券对应商品
static NSString* const YWBackCouponString = @"couponInformation/shoppingBackCouponToUser"; //优惠券返还

//首页相关
static NSString* const YWHomeAdsString = @"advertisementInformation/getEffectAdvertisementByType"; //
static NSString* const YWHomeHotString = @"advertisementInformation/getAdvertisementById"; //

//售后相关
static NSString* const YWCustomerString = @"customerService/getCustomerServiceByUserIdAndId"; //
static NSString* const YWCustomerByOrderString = @"customerService/getCustomerServiceByUserIdAndOrderId"; //
static NSString* const YWSetCustomerString = @"customerService/applyCustomerService"; //申请售后

//我的相关
static NSString* const YWUpdateUserNameString = @"user/updateUserName"; //
static NSString* const YWUpdateUserPicString = @"user/updateUserPicUrl"; //
static NSString* const YWGetMessageNumString = @"user/getMessageNum";
static NSString* const YWGetMessageOrderListString = @"user/getOrderStateDetailList";
static NSString* const YWUpdateOrderStautsString = @"user/updateOrderMSGStauts";// 订单消息已读
static NSString* const YWUpdateActivityStautsString = @"user/updateActivityMSGStauts"; // 活动消息已读
static NSString* const YWDeldectMessageString = @"user/deldectMessage"; // 清除消息
static NSString* const YWActivityMessageListString = @"activityInformation/getActivityMessageByUserId"; // 活动消息
static NSString* const YWActivityInformationString = @"activityInformation/getActivityInformationById"; // 活动详情

//支付相关
static NSString* const YWWeChatPayString = @"WeChatApi/getOrderInfo"; // 微信付款
static NSString* const YWWeChatPayResultString = @"WeChatApi/orderQuery"; // 微信结果确认
static NSString* const YWAliPayString = @"AlipayApi/getOrderInfo"; // 支付宝付款
static NSString* const YWAliPayResultString = @"AlipayApi/getOrderState"; // 支付宝结果确认
static NSString* const YWAliPayAuthString = @"AlipayApi/getAuthInfo"; // 支付宝授权

static NSString* const YWOfflinePaymentString = @"offlinePayment/insertOfflinePayment"; // 线下付款

//html
static NSString* const YWServiceHtmlString = @"http://117.158.178.202:8004/JLKF/chatClient?loginName=";
static NSString* const YWGoodsDetailHtmlString = @"junlin/mis_jsp/webview/goodsDetails.jsp";

#endif /* Api_h */









