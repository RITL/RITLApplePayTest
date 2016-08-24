//
//  ViewController.h
//  ApplePayDemo
//
//  Created by YueWen on 16/8/15.
//  Copyright © 2016年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKContact;
@class PKShippingMethod;
@class PKPaymentMethod;

NS_ASSUME_NONNULL_BEGIN


@interface ViewController : UIViewController


@end



@interface PayMentModel : NSObject



/// 支付方式
@property (nonatomic, strong) PKPaymentMethod * paymentMethod;

/// 配送方式
@property (nonatomic, strong) PKShippingMethod * shipMethod;

/// 收货联系人
@property (nonatomic, strong) PKContact * contact;


@end

NS_ASSUME_NONNULL_END

