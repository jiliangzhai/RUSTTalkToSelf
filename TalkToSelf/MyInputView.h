//
//  MyInputView.h
//  TalkToSelf
//
//  Created by rust_33 on 16/1/29.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyInputViewDelegate <NSObject>

- (void)sendTextMessage:(NSString *)TextMessage;
- (void)sendPicMessage:(UIImage *)PicMessage;
- (void)sentVoiceMessage:(NSData *)voiceMessage duration:(NSInteger)duration;
- (void)heightOfTextViewChangedBy:(float)height;

@end

@interface MyInputView : UIView

@property(nonatomic,strong)UIButton *sendMessageButton;
@property(nonatomic,strong)UIButton *changeStateButton;
@property(nonatomic,strong)UIButton *voiceHoldButton;
@property(nonatomic,strong)UILabel *messageHoldLabel;
@property(nonatomic,strong)UITextView *textInputView;
@property(nonatomic,strong)UIViewController *superController;
@property(nonatomic)BOOL isAbleToSendMessage;
@property(nonatomic,weak)id<MyInputViewDelegate>delegate;

- (instancetype)initPrivate;
- (void)changeSendButton:(BOOL)isPhoto;

@end
