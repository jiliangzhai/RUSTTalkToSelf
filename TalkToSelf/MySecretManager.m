//
//  MySecretManager.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/24.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MySecretManager.h"
#import "MyKeyChainService.h"
#import "MyUserManager.h"

@implementation MySecretManager

+ (NSString *)getPassword
{
    NSString *keyinKeyChain = @"com.rust.password";
    keyinKeyChain = [keyinKeyChain stringByAppendingString:[MyUserManager initDate]];
    NSString *service = @"com.rust.secret.service";
    service = [service stringByAppendingString:[MyUserManager initDate]];
    NSMutableDictionary* dic = (NSMutableDictionary *)[MyKeyChainService load:service];
    return [dic objectForKey:keyinKeyChain];
}

+ (void)savePassword:(NSString *)password
{
    NSString *keyinKeyChain = @"com.rust.password";
    keyinKeyChain = [keyinKeyChain stringByAppendingString:[MyUserManager initDate]];
    NSString *service = @"com.rust.secret.service";
    service = [service stringByAppendingString:[MyUserManager initDate]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:password forKey:keyinKeyChain];
    [MyKeyChainService save:service data:dic];
}
@end
