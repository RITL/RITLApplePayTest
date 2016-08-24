//
//  PKShippingMethod+Category.h
//  ApplePayDemo
//
//  Created by YueWen on 16/8/15.
//  Copyright © 2016年 YueWen. All rights reserved.
//

#import <PassKit/PassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKShippingMethod (Category)


/**
 *  获得送货方式的便利构造器
 *
 *  @param label      当前的标签
 *  @param amount     价格,类型支持小数型的NSNumber
 *  @param identifier 必须有的标志位
 *  @param detail     详细消息，比如多久后到等备注消息
 *
 *  @return 创建好的PKShippingMethod对象
 */
+ (instancetype)shippingMethodWithLabel:(NSString *)label amount:(NSDecimalNumber *)amount identifier:(NSString *)identifier detail:(nullable NSString *)detail;


/**
 *  获得送货方式的便利构造器
 *
 *  @param label      当前的标签
 *  @param amount     价格，直接字符串
 *  @param identifier 必须有的标志位
 *  @param detail     详细消息
 *
 *  @return 创建好的PKShippingMethod对象
 */
+ (instancetype)shippingMethodWithLabel:(NSString *)label amountString:(NSString *)amount identifier:(NSString *)identifier detail:(nullable NSString *)detail;

@end


@interface CNPostalAddress (Category)

/// 一个详细的地址，方便打印..
@property (nullable,nonatomic,readonly,strong)NSString * fullAddress;

@end

NS_ASSUME_NONNULL_END