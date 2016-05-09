//
//  MyMessage.m
//  TalkToSelf
//
//  Created by rust_33 on 16/5/6.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyMessage.h"
#import "MyUserManager.h"
#import "MyDataSourcemanager.h"

@implementation MyMessage

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        NSString *userName = [dic objectForKey:@"userName"];
        NSString *createdTime = [dic objectForKey:@"createdTime"];
        UIImage *thumbnail = [dic objectForKey:@"thumbnail"];
        _userName = userName;
        _createdTime = createdTime;
        _thumbnail = thumbnail;
        _messageOriation = (MessageOriation)[[dic objectForKey:@"messageOriation"] integerValue];
        switch ([[dic objectForKey:@"messageType"] integerValue]) {
            case 0:
                _messageType = TextMessage;
                _textMessage = [dic objectForKey:@"textMessage"];
                break;
            case 1:
                _messageType = PicMessage;
                _picMessage = [dic objectForKey:@"picMessage"];
                break;
            case 2:
                _messageType = VoiceMessage;
                _voiceMessage = [dic objectForKey:@"voiceMessage"];
                _voiceDuration = [[dic objectForKey:@"voiceDuration"] integerValue];
            default:
                break;
        }
    }
    return self;
}

- (void)completeTheMessage
{
    switch (self.messageType) {
        case 0:
            self.textMessage = self.messageBody;
            break;
        case 1:
            self.picMessage = [UIImage getTheImageWithName:self.messageBody];
            break;
        case 2:
            self.voiceMessage = [NSData getTheDataWithName:self.messageBody];
        default:
            break;
    }
    if (self.messageOriation == isFormSelf) {
        self.userName = [MyUserManager userName];
        self.thumbnail = [UIImage imageWithData:[MyUserManager userThumbnail]];
    }else
    {
        self.userName = [MyUserManager targetNameAtIndex:[MyUserManager lastTargetIndex]];
        self.thumbnail = [UIImage imageWithData:[MyUserManager targetThumbnailAtIndex:[MyUserManager lastTargetIndex]]];
    }
}
@end

