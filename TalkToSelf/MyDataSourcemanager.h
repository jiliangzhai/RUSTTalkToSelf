//
//  MyDataSourcemanager.h
//  TalkToSelf
//
//  Created by rust_33 on 16/3/1.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MyCellFrame;
@class MyMessage;


@protocol MyDateSourceDelegate <NSObject>

@optional
- (void)newMessageAdded:(MyCellFrame *)message;
- (void)deleteMessage:(MyMessage *)message;

@end

@interface UIImage (store)

+ (UIImage *)getTheImageWithName:(NSString *)name;
- (NSString *)storeTheImage;

@end

@interface NSData (store)

+ (NSData *)getTheDataWithName:(NSString *)name;
- (NSString *)storeTheData;

@end

@interface MyDataSourcemanager : NSObject

@property(nonatomic,weak)id<MyDateSourceDelegate>delegate;
+ (instancetype)sharedManager;
+ (NSArray *)dataSources;
+ (NSInteger)numOfMessageAtindex:(NSInteger)index;
+ (void)dataSourcesWithNum:(NSInteger)num index:(NSInteger)index;
+ (void)reloadMessageNum:(NSInteger)num index:(NSInteger)index;
+ (void)addMessage:(MyMessage *)message index:(NSInteger)index;
+ (void)initSystemMessageAtIndex:(NSInteger)index;
+ (void)creatNewTableAtIndex:(NSInteger)index;
+ (void)removeAllMessageAtIndex:(NSInteger)index;
+ (void)removeMessage:(MyCellFrame *)frame index:(NSInteger)index;

+ (NSInteger)numOfPicMessageAtindex:(NSInteger)index;
+ (NSInteger)numOfTextMessageAtindex:(NSInteger)index;
+ (NSInteger)numOfVoiceMessageAtindex:(NSInteger)index;


@end
