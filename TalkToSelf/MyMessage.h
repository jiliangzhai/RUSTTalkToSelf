//
//  MyMessage.h
//  TalkToSelf
//
//  Created by rust_33 on 16/5/6.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MessageButton;

typedef NS_ENUM(NSInteger,MessageType)
{
    TextMessage = 0,
    PicMessage,
    VoiceMessage
};
typedef NS_ENUM(NSInteger,MessageOriation)
{
    isFormSelf = 0,
    isFormSystem
};

@interface MyMessage : NSObject

@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)UIImage *thumbnail;
@property(nonatomic,copy)NSString *createdTime;
@property(nonatomic,strong)MessageButton *messageButton;
@property(nonatomic)MessageType messageType;
@property(nonatomic)MessageOriation messageOriation;
@property(nonatomic,strong)NSString *messageBody;

@property(nonatomic,copy)NSString *textMessage;
@property(nonatomic,copy)UIImage *picMessage;
@property(nonatomic,copy)NSData *voiceMessage;
@property(nonatomic)NSInteger voiceDuration;
@property(nonatomic)BOOL showTimeLabel;

- (instancetype)initWithDic:(NSDictionary *)dic;
- (void)completeTheMessage;
@end
