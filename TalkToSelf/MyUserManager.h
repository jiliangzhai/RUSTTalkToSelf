//
//  MyUserManager.h
//  TalkToSelf
//
//  Created by rust_33 on 16/3/4.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyUserManager : NSObject

+ (instancetype)sharedUserManager;
+ (NSMutableDictionary *)userDic;
+ (NSString *)userName;
+ (NSData *)userThumbnail;
+ (NSString *)targetNameAtIndex:(NSInteger)index;
+ (NSMutableArray *)targetNames;
+ (NSData *)targetThumbnailAtIndex:(NSInteger)index;
+(NSMutableArray *)targetThumbnails;
+ (NSInteger)lastTargetIndex;
+ (NSString *)initDate;
+ (NSInteger)activeDays;
+ (void)newActiveDay;
+ (NSInteger)numOfMessage;
+ (void)changeUserNameTo:(NSString *)newName;
+ (void)changeTargetNameTo:(NSString *)newName atIndex:(NSInteger)index;
+ (void)changeThumbnailTo:(UIImage *)image;
+ (void)addTargetName:(NSString *)name thumbnail:(UIImage *)thumbnail;
+ (void)removeTargetNamed:(NSString *)name;
+ (void)changeTargetThumbnail:(UIImage *)image atIndex:(NSInteger)index;
+ (void)changeLastTargetIndexto:(NSInteger)index;
+ (void)addKissAtIndex:(NSInteger)index;
+ (void)addPunchAtIndex:(NSInteger)index;
+ (BOOL)willShowSystemmessage;
+ (void)showSystem:(BOOL)show;
+ (NSInteger)kissNumAtIndex:(NSInteger)index;
+ (NSInteger)punchNumAtIndex:(NSInteger)index;
+ (void)save;
@end
