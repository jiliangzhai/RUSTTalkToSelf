//
//  MySecretManager.h
//  TalkToSelf
//
//  Created by rust_33 on 16/3/24.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySecretManager : NSObject

+ (NSString *)getPassword;
+ (void)savePassword:(NSString *)password;

@end
