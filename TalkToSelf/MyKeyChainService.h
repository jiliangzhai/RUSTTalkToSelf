//
//  MyKeyChainService.h
//  TalkToSelf
//
//  Created by rust_33 on 16/3/24.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyKeyChainService : NSObject

+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;

@end
