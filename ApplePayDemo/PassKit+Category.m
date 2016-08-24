//
//  PKShippingMethod+Category.m
//  ApplePayDemo
//
//  Created by YueWen on 16/8/15.
//  Copyright © 2016年 YueWen. All rights reserved.
//

#import "PKShippingMethod+Category.h"

@implementation PKShippingMethod (Category)

+(instancetype)shippingMethodWithLabel:(NSString *)label amount:(NSDecimalNumber *)amount identifier:(NSString *)identifier detail:(NSString *)detail
{
    PKShippingMethod * shippingMethod = [PKShippingMethod summaryItemWithLabel:label amount:amount];
    
    shippingMethod.identifier = identifier;
    shippingMethod.detail = detail;
    
    return shippingMethod;
}


+(instancetype)shippingMethodWithLabel:(NSString *)label amountString:(NSString *)amount identifier:(NSString *)identifier detail:(NSString *)detail
{
    NSDecimalNumber * amountNumber = [NSDecimalNumber decimalNumberWithString:amount];
    
    return [self shippingMethodWithLabel:label amount:amountNumber identifier:identifier detail:detail];
}

@end
