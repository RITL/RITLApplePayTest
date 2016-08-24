//
//  ViewController.m
//  ApplePayDemo
//
//  Created by YueWen on 16/8/15.
//  Copyright © 2016年 YueWen. All rights reserved.
//

#import "ViewController.h"
#import "PassKit+Category.h"

@import PassKit;


#ifdef DEBUG


#define DLog( s, ... ) NSLog( @"< %@:(%d) > %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

#define DLog(s, ...)

#endif

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>
{
    NSArray * _payNetworks;
}

//interface builder
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *paySignLabel;

@property (weak, nonatomic) IBOutlet PKPaymentButton *purseButton;//只能通过代码添加

//Data
@property (nonatomic, strong) PayMentModel * payModel;
@property (nonatomic, assign, getter=isPaySuccess)BOOL paySuccess;

/// 付款选项
@property (nonatomic, copy)NSArray < PKPaymentSummaryItem * > * paymentSummaryItems;

/// 送货方式
@property (nonatomic, copy)NSArray < PKShippingMethod * > * shippingMethods;

@end


@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _payModel = [PayMentModel new];
    _payNetworks = @[PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay,PKPaymentNetworkMasterCard];//支持的支付网络
    
    
    //创建applePayButton
    _purseButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    _purseButton.frame = self.button.frame;
    [_purseButton addTarget:self action:@selector(purseButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.button removeFromSuperview];
    [self.view addSubview:_purseButton];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)purseButtonDidTap:(id)sender
{
    [self.priceTextField resignFirstResponder];
    [self.numberTextField resignFirstResponder];
    
    //点击
    DLog(@"\n购买啦\n购买单价%@\n购买数量%@\n",self.priceTextField.text,self.numberTextField.text);
    
#ifdef __IPHONE_9_2
    //改变label的值
    self.paySignLabel.text = @"正在付款...";
    
    
//    if (![PKPaymentAuthorizationViewController canMakePayments])
//    {
//        return;
//    }
//    
//    DLog(@"可以支付!");
    
    //进行判断
    if(![PKPaymentAuthorizationViewController canMakePayments])
    {
        DLog(@"不能做支付");
        return;
    }
    
    
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:_payNetworks])
    {
        DLog(@"不支持网络支付方式!");return;
    }
    
    
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:_payNetworks capabilities:PKMerchantCapability3DS | PKMerchantCapabilityDebit | PKMerchantCapabilityCredit | PKMerchantCapabilityEMV])
    {
        DLog(@"不能支持3DS等"); return;
    }
    
    //弹出控制器
    PKPaymentAuthorizationViewController * viewController = [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:[self paymentRequest]];
    
    viewController.delegate = self;
    
    //执行代理
    [self presentViewController:viewController animated:true completion:^{}];
    
#endif
    
}




#ifdef __IPHONE_9_2

#pragma mark - <PKPaymentAuthorizationViewControllerDelegate>


/// 进行验证并进行回调
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    //状态的变量
    PKPaymentAuthorizationStatus status = PKPaymentAuthorizationStatusSuccess;
    _paySuccess = true;
    
    
    //如果收件人联系方式或者收货地址为空
    if (payment.billingContact.postalAddress == nil)
    {
        status = PKPaymentAuthorizationStatusInvalidBillingPostalAddress;
        _paySuccess = false;
    }
    
    else if(payment.shippingContact.phoneNumber == nil)
    {
        status = PKPaymentAuthorizationStatusInvalidShippingContact;
        _paySuccess = false;
    }
    
    //可以在此处提交订单......根据返回结果，回调completion()
    //
    //
    //
    //
    
    //打印订单信息
    NSLog(@"订单信息:");
    NSLog(@"billingContact.address = %@",payment.billingContact.postalAddress.fullAddress);
    NSLog(@"billContact.person = %@",payment.billingContact);
    NSLog(@"identifier = %@ , detail = %@",payment.shippingMethod.identifier,payment.shippingMethod.detail);
    NSLog(@"phone = %@",payment.shippingContact.phoneNumber.stringValue);
    NSLog(@"加密的数据---太长，不打印了，payment.token.paymentData");
    NSLog(@"支付卡类型: %ld ",payment.token.paymentMethod.type);
    
    
    //进行回调
    completion(status);
    
}



// 验证完毕或者直接点击取消进行的回调
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    if (_paySuccess == false)//支付成功
    {
        _paySignLabel.text = @"支付失败!";
    }
    
    
    else{
        
        _paySignLabel.text = @"支付成功!";
        
    }
    
    //消除支付界面
    [controller dismissViewControllerAnimated:true completion:^{}];
}


//在Touchid 或者 password(有的银行还是需要密码验证的呢) 验证之后的回调，点击取消则不会响应该方法
- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller NS_AVAILABLE_IOS(8_3)
{

    
//    DLog(@"%@",NSStringFromSelector(@selector(paymentAuthorizationViewControllerWillAuthorizePayment:)));
}


//选中一个送货方式后进行的回调
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray<PKPaymentSummaryItem *> *summaryItems))completion
{
    //用来记录送货方式
    _payModel.shipMethod = shippingMethod;
    
    //获得配送方式的标签
//    DLog(@"shippingMethod = %@，detail = %@",shippingMethod.label,shippingMethod.detail);
    
//    DLog(@"%@",NSStringFromSelector(@selector(paymentAuthorizationViewController:didSelectShippingMethod:completion:)));
    
    //进行回调更新数据
    completion(PKPaymentAuthorizationStatusSuccess,@[shippingMethod]);
}


//选中一个送货联系人
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                  didSelectShippingContact:(PKContact *)contact
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray<PKShippingMethod *> *shippingMethods,
                                                     NSArray<PKPaymentSummaryItem *> *summaryItems))completion
{
    //记录配送联系人
    _payModel.contact = contact;
    
//    DLog(@"contactAddress = %@",contact.postalAddress.fullAddress);
    
//    DLog(@"%@",NSStringFromSelector(@selector(paymentAuthorizationViewController:didSelectShippingContact:completion:)));
    
    //进行回调更新数据
    completion(PKPaymentAuthorizationStatusSuccess,self.shippingMethods,self.paymentSummaryItems);
    
}


// 选中一个新的支付方式
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                    didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod
                                completion:(void (^)(NSArray<PKPaymentSummaryItem *> *summaryItems))completion
{
    //记录支付方式
    _payModel.paymentMethod = paymentMethod;
    
//    DLog(@"method = %@",paymentMethod.displayName);
    
//    DLog(@"%@",NSStringFromSelector(@selector(paymentAuthorizationViewController:didSelectPaymentMethod:completion:)));
    
    //进行回调更新数据
    completion(self.paymentSummaryItems);
    
}



#endif



#pragma mark - Source

- (PKPaymentRequest *)paymentRequest
{
    PKPaymentRequest * payRequest = [PKPaymentRequest new];
    
    //相关配置
    
    //证书identifier
    payRequest.merchantIdentifier = @"merchant.com.yue.ApplePay";
    //两字母的 ISO 3166 国家代码
    payRequest.countryCode = @"CN";
    //三字母的 ISO 4217 货币代码
    payRequest.currencyCode = @"CNY";
    //支持的支付网络
    payRequest.supportedNetworks = _payNetworks;
    //支持的银行卡类型
    payRequest.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityDebit | PKMerchantCapabilityCredit | PKMerchantCapabilityEMV;
    //支付信息
    payRequest.paymentSummaryItems = self.paymentSummaryItems;
    //必须要有的账单地址选项,默认为None
    payRequest.requiredBillingAddressFields = PKAddressFieldPostalAddress;
    //必须要有的收货人联系方式选项,默认为None
    payRequest.requiredShippingAddressFields = PKAddressFieldPhone | PKAddressFieldPostalAddress;
    //送货方式，默认为nil
    payRequest.shippingMethods = [self shippingMethods];
    //送货类型
    payRequest.shippingType = PKShippingTypeDelivery;
    payRequest.applicationData = [@"我是RITL,来收费啦" dataUsingEncoding:NSUTF8StringEncoding];
    
    return payRequest;
}


//#pragma - 必须有的地址域
//typedef NS_OPTIONS(NSUInteger, PKAddressField) {
//    PKAddressFieldNone              //默认是不需要任何地址
//    PKAddressFieldPostalAddress     // 一个完整的地址，包含国家，邮政编码，省/区，城市，街道，姓名等
//    PKAddressFieldPhone             //电话
//    PKAddressFieldEmail             //邮箱
//    PKAddressFieldName NS_ENUM_AVAILABLE_IOS(8_3)//姓名
//    PKAddressFieldAll               //包含以上所有信息
//} NS_ENUM_AVAILABLE(NA, 8_0);


//#pragma - 送货方法
//typedef NS_ENUM(NSUInteger, PKShippingType) {
//    PKShippingTypeShipping,     //默认为第三方发货，比如顺丰、圆通等..
//    PKShippingTypeDelivery,     //卖家自己配送
//    PKShippingTypeStorePickup,  //场家直送
//    PKShippingTypeServicePickup //买家自提
//} NS_ENUM_AVAILABLE(NA, 8_3);


//#pragma - 支付卡类型
//typedef NS_OPTIONS(NSUInteger, PKMerchantCapability) {
//    PKMerchantCapability3DS,        //美国的一种卡类型，必须支持!
//    PKMerchantCapabilityEMV,        //欧洲的卡
//    PKMerchantCapabilityCredit,     //信用卡
//    PKMerchantCapabilityDebit       //借记卡
//} NS_ENUM_AVAILABLE(NA, 8_0);


////美国运通
//extern NSString * const PKPaymentNetworkAmex NS_AVAILABLE(NA, 8_0);
////中国银联
//extern NSString * const PKPaymentNetworkChinaUnionPay NS_AVAILABLE(NA, 9_2);
//
////一下两个不太懂，看不明白..
//extern NSString * const PKPaymentNetworkDiscover NS_AVAILABLE(NA, 9_0);
//extern NSString * const PKPaymentNetworkInterac NS_AVAILABLE(NA, 9_2);
//
////万事达信用卡
//extern NSString * const PKPaymentNetworkMasterCard NS_AVAILABLE(NA, 8_0);
////商城的信用卡和借记卡
//extern NSString * const PKPaymentNetworkPrivateLabel NS_AVAILABLE(NA, 9_0);
////Visa卡
//extern NSString * const PKPaymentNetworkVisa NS_AVAILABLE(NA, 8_0);


//- (NSArray *)paymentSummaryItems

- (NSArray<PKPaymentSummaryItem *> *)paymentSummaryItems
{
    if (_paymentSummaryItems == nil)
    {
        //设置付款选项
        PKPaymentSummaryItem * priceItem = [PKPaymentSummaryItem summaryItemWithLabel:@"单价" amount:[NSDecimalNumber decimalNumberWithString:self.priceTextField.text]];
        
        PKPaymentSummaryItem * numberItem = [PKPaymentSummaryItem summaryItemWithLabel:@"数量" amount:[NSDecimalNumber decimalNumberWithString:self.numberTextField.text]];
        
        //计算总价字符串，最后一个必须是总价
        NSString * sumPrice = [NSString stringWithFormat:@"%@",@(self.priceTextField.text.integerValue * self.numberTextField.text.integerValue)];
        
        PKPaymentSummaryItem * sumItem = [PKPaymentSummaryItem summaryItemWithLabel:@"RITL" amount:[NSDecimalNumber decimalNumberWithString:sumPrice]];
        
        _paymentSummaryItems = @[priceItem,numberItem,sumItem];
    }
    return _paymentSummaryItems;
}


/// 送货方式，默认为第一个
- (NSArray<PKShippingMethod *> *)shippingMethods
{
    if (_shippingMethods == nil)
    {
        //设置收货人送货选项
        PKShippingMethod * method1 = [PKShippingMethod shippingMethodWithLabel:@"顺丰" amountString:@"20" identifier:@"shunfeng" detail:@"预计两天后到达"];
        
        PKShippingMethod * method2 = [PKShippingMethod shippingMethodWithLabel:@"圆通" amountString:@"18" identifier:@"yuantong" detail:@"预计一天后发货"];
        
        PKShippingMethod * method3 = [PKShippingMethod shippingMethodWithLabel:@"RITL" amountString:@"5" identifier:@"RITL" detail:@"估计就没了.."];
        
        _shippingMethods = @[method1,method2,method3];
        
        //默认
        _payModel.shipMethod = method1;
    }

    return _shippingMethods;
}

@end


@implementation PayMentModel



@end




