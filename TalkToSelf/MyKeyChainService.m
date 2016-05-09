//
//  MyKeyChainService.m
//  TalkToSelf
//
//  Created by rust_33 on 16/3/24.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyKeyChainService.h"
#import <Security/Security.h>

@implementation MyKeyChainService

+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,service,(__bridge id)kSecAttrService,service,(__bridge id)kSecAttrAccount,(__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,nil];
}

+ (void)save:(NSString *)service data:(id)data
{
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keyChainQuery);
    [keyChainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge_retained CFDictionaryRef)keyChainQuery, NULL);
}

+ (id)load:(NSString *)service
{
    id result = nil;
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery:service];
    
    [keyChainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keyChainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFDataRef keyData = NULL;
    
    OSStatus status = SecItemCopyMatching((__bridge_retained CFDictionaryRef)keyChainQuery,(CFTypeRef *)&keyData);
    if (status == noErr) {
        
        @try{
            result = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        }@catch(NSException *e){
            NSLog(@"unarchiver of %@ failed %@",service,e);
        }@finally{
            
        }
    }else
        NSLog(@"%i",(int)status);
    
    return result;
}
@end
