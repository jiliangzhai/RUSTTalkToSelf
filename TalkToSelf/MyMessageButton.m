//
//  MyMessageButton.m
//  TalkToSelf
//
//  Created by rust_33 on 16/5/6.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyMessageButton.h"

@interface MyMessageButton (){
    
    UIActivityIndicatorView *indicator;
}

@end

@implementation MyMessageButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.picImageView = [[UIImageView alloc] initWithFrame:frame];
        self.picImageView.userInteractionEnabled = NO;
        self.picImageView.hidden = YES;
        
        self.voiceView = [[UIView alloc] init];
        self.voiceView.userInteractionEnabled = NO;
        self.voiceView.hidden = YES;
        self.voicePic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_animation_white3.png"]];
        self.voicePic.frame = CGRectMake(110, 10, 20, 20);
        self.voicePic.animationImages = @[[UIImage imageNamed:@"chat_animation_white1.png"],
                                          [UIImage imageNamed:@"chat_animation_white2.png"],
                                          [UIImage imageNamed:@"chat_animation_white3.png"]];
        self.voicePic.animationDuration = 1;
        self.voicePic.animationRepeatCount = 0;
        
        self.voiceDuration = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 70, 30)];
        self.voiceDuration.textAlignment = NSTextAlignmentCenter;
        self.voiceDuration.textColor = [UIColor grayColor];
        self.voiceDuration.font = [UIFont systemFontOfSize:16];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.center = CGPointMake(110, 20);
        
        [self.voiceView addSubview:indicator];
        [self.voiceView addSubview:self.voicePic];
        [self.voiceView addSubview:self.voiceDuration];
        
        [self addSubview:self.picImageView];
        [self addSubview:self.voiceView];
    }
    return self;
}

- (void)setIsFormSelf:(BOOL)isFormSelf
{
    self.isFromSelf = isFormSelf;
    if (isFormSelf){
        self.titleLabel.textColor = [UIColor blackColor];
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 25);
        self.bgImage = [UIImage imageNamed:@"chatto_bg_normal.png"];
        self.bgImage = [self.bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
    }else{
        self.titleLabel.textColor = [UIColor whiteColor];
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 25, 10, 15);
        self.bgImage = [UIImage imageNamed:@"chatfrom_bg_normal.png"];
        self.bgImage = [self.bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22,10, 10)];
    }
    [self setBackgroundImage:self.bgImage forState:UIControlStateNormal];
    [self setBackgroundImage:self.bgImage forState:UIControlStateHighlighted];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
}

- (void)beginLoadVoice
{
    self.voiceView.hidden = YES;
    [indicator startAnimating];
}

- (void)didLoadVoice
{
    self.voiceView.hidden = NO;
    [self.voicePic startAnimating];
}

- (void)stopVoicePlay
{
    [self.voicePic stopAnimating];
}

#pragma copy function

/*- (BOOL)canBecomeFirstResponder
 {
 return YES;
 }
 
 - (BOOL)canPerformAction:(SEL)action withSender:(id)sender
 {
 return (action == @selector(copyText:) || (action == @selector(deleteMessage:)));
 }
 
 - (void)copyText:(id)sender
 {
 UIPasteboard *pateBoard = [UIPasteboard generalPasteboard];
 pateBoard.string = self.titleLabel.text;
 }
 
 - (void)deleteMessage:(id)sender
 {
 
 }*/

@end
