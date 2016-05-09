//
//  MyMessageButton.h
//  TalkToSelf
//
//  Created by rust_33 on 16/5/6.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyMessage;

@interface MyMessageButton : UIButton

@property(nonatomic,strong) UIImageView *picImageView;
@property(nonatomic,strong) UIView *voiceView;
@property(nonatomic,strong) UIImageView *voicePic;
@property(nonatomic,strong) UILabel *voiceDuration;
@property(nonatomic,strong) UIImage *bgImage;
@property(nonatomic)BOOL isFromSelf;
- (void)setIsFormSelf:(BOOL)isFormSelf;
- (void)beginLoadVoice;
- (void)didLoadVoice;
- (void)stopVoicePlay;

@end
