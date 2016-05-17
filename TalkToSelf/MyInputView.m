//
//  MyInputView.m
//  TalkToSelf
//
//  Created by rust_33 on 16/1/29.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyInputView.h"
#import "Mp3Recorder.h"
#import "MyRecordProgressView.h"


@interface MyInputView ()<UITextViewDelegate,Mp3RecorderDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL beginVoiceRecorde;
    Mp3Recorder *MP3;
    NSInteger playTime;
    NSTimer *playTimer;
    CGFloat originalHeight;
    CGFloat padding;
    CGFloat topBottom;
    BOOL lastSendButtonState;
}

@end

@implementation MyInputView

- (instancetype)initPrivate
{
    CGFloat screenH = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat screenW = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGRect frame = CGRectMake(0,screenH-50, screenW, 50);
    self = [super initWithFrame:frame];
    if (self) {
        
        MP3 = [[Mp3Recorder alloc] initWithDelegate:self];
        self.backgroundColor = [UIColor whiteColor];
        
        _sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendMessageButton.frame = CGRectMake(screenW-50, 5, 40, 40);
        _sendMessageButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _sendMessageButton.titleLabel.text = @"";
        [_sendMessageButton setBackgroundImage:[UIImage imageNamed:@"Chat_take_picture.png"] forState:UIControlStateNormal];
        [_sendMessageButton addTarget:self action:@selector(sendMessageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _isAbleToSendMessage = NO;
        [self addSubview:_sendMessageButton];
        
        _changeStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeStateButton.frame = CGRectMake(10, 5, 40, 40);
        [_changeStateButton setBackgroundImage:[UIImage imageNamed:@"chat_voice_record.png"] forState:UIControlStateNormal];
        [_changeStateButton addTarget:self action:@selector(changeMessageState:) forControlEvents:UIControlEventTouchUpInside];
        beginVoiceRecorde = NO;
        [self addSubview:_changeStateButton];
        
        _voiceHoldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceHoldButton.frame = CGRectMake(70, 5, screenW-140, 40);
        _voiceHoldButton.hidden = YES;
        _voiceHoldButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_voiceHoldButton setBackgroundImage:[UIImage imageNamed:@"chat_message_back.png"] forState:UIControlStateNormal];
        [_voiceHoldButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_voiceHoldButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_voiceHoldButton setTitle:@"press to recorder" forState:UIControlStateNormal];
        [_voiceHoldButton setTitle:@"release to send" forState:UIControlStateHighlighted];
        [_voiceHoldButton addTarget:self action:@selector(beginToRecorde:) forControlEvents:UIControlEventTouchDown];
        [_voiceHoldButton addTarget:self action:@selector(didFinishRecord:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceHoldButton addTarget:self action:@selector(cancelVoiceRecord:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        [self addSubview:_voiceHoldButton];
        
        _textInputView = [[UITextView alloc] initWithFrame:CGRectMake(55, 5, screenW-110, 40)];
        _textInputView.font = [UIFont systemFontOfSize:20];
        _textInputView.layer.cornerRadius = 4;
        _textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textInputView.layer.borderWidth = 1.0;
        _textInputView.layer.masksToBounds = YES;
        _textInputView.delegate = self;
        [self addSubview:_textInputView];
        
        /*_messageHoldLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(_textInputView.frame)-40, 30)];
        _messageHoldLabel.textColor = [UIColor lightGrayColor];
        _messageHoldLabel.textAlignment = NSTextAlignmentCenter;
        _messageHoldLabel.text = @"input here";
        [_textInputView addSubview:_messageHoldLabel];*/
        
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:UIKeyboardWillHideNotification object:nil];
        padding = _textInputView.contentInset.left+_textInputView.contentInset.right+_textInputView.textContainerInset.left+_textInputView.textContainerInset.right+_textInputView.textContainer.lineFragmentPadding+_textInputView.textContainer.lineFragmentPadding;
        topBottom = _textInputView.contentInset.top+_textInputView.contentInset.bottom+_textInputView.textContainerInset.top+_textInputView.textContainerInset.bottom;
    }
    
    return self;
}

- (void)sendMessageButtonPressed:(UIButton *)button
{
    //发送按键点击
    lastSendButtonState = !lastSendButtonState;
    if (self.isAbleToSendMessage) {
        NSString *message = [self.textInputView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![message isEqualToString:@""]) {
            [self.delegate sendTextMessage:message];
            [self.textInputView resignFirstResponder];
        }else
        {   self.textInputView.text = @"";
            [self changeSendButton:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"发送内容为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
        }
    }else
    {
        [_textInputView resignFirstResponder];
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相机",@"相册", nil];
        [sheet showInView:self.window];
    }
}

- (void)changeMessageState:(UIButton *)button
{
    //转换消息模式
    _voiceHoldButton.hidden = !_voiceHoldButton;
    _textInputView.hidden = !_textInputView.hidden;
    beginVoiceRecorde = !beginVoiceRecorde;
    if (beginVoiceRecorde) {
        [_changeStateButton setBackgroundImage:[UIImage imageNamed:@"chat_ipunt_message.png"] forState:UIControlStateNormal];//change
        [_textInputView resignFirstResponder];
    }else
    {
        [_changeStateButton setBackgroundImage:[UIImage imageNamed:@"chat_voice_record.png"] forState:UIControlStateNormal];//change
        [_textInputView becomeFirstResponder];
    }

}

#pragma mark recorde button touched
- (void)beginToRecorde:(UIButton *)button
{
    //开始录音
    [MP3 startRecord];
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
    
    [MyRecordProgressView start];
}

- (void)timerCount
{
    //超时结束录音
    playTime++;
    if (playTime>60) {
        [self didFinishRecord:nil];
    }
}

- (void)didFinishRecord:(UIButton *)button
{
    //结束录音
    if (playTimer) {
        [MP3 stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    
}

- (void)cancelVoiceRecord:(UIButton *)button
{
    //取消录音
    if (playTimer) {
        [MP3 cancelRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
    _voiceHoldButton.userInteractionEnabled = NO;
    [MyRecordProgressView stopWithRecprderCanceled];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _voiceHoldButton.userInteractionEnabled = YES;
    });
}

- (void)changeSendButton:(BOOL)isPhoto
{
    //发送按键与照片按键切换
    if (isPhoto)
        _textInputView.frame = CGRectMake(55, 5,CGRectGetWidth([UIScreen mainScreen].bounds)-110, 40);
    self.isAbleToSendMessage = !isPhoto;
    [self.sendMessageButton setTitle:isPhoto?@"":@"send" forState:UIControlStateNormal];
    UIImage *image = [UIImage imageNamed:isPhoto?@"Chat_take_picture":@"chat_send_message"];//change
    [self.sendMessageButton setBackgroundImage:image forState:UIControlStateNormal];

}

#pragma Mp3RecorderDelegate method
- (void)endConvertWithData:(NSData *)voiceData
{
    [self.delegate sentVoiceMessage:voiceData duration:playTime];
    _voiceHoldButton.userInteractionEnabled = NO;
    [MyRecordProgressView stopWithSuccess];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _voiceHoldButton.userInteractionEnabled = YES;
    });
}

- (void)failRecord
{
    _voiceHoldButton.userInteractionEnabled = NO;
    [MyRecordProgressView stopWithTooShortRecorder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _voiceHoldButton.userInteractionEnabled = YES;
    });
}

#pragma UITextViewDelegate  method

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //用户开始编辑文本消息
    _messageHoldLabel.hidden = _textInputView.text.length>0;
    lastSendButtonState = YES;
    CGRect rect = [[textView layoutManager] usedRectForTextContainer:[textView textContainer]];
    originalHeight = CGRectGetHeight(rect);
}
- (void)textViewDidChange:(UITextView *)textView
{
    //文本消息变化
    CGSize size;
    CGRect rect = [[textView layoutManager] usedRectForTextContainer:[textView textContainer]];
    size = rect.size;
    CGFloat height = ceilf(CGRectGetHeight(rect));
    if (height!=originalHeight) {
        [self resizeAccordingToTextViewHeightChangedBy:height];
        originalHeight = height;
    }
    BOOL newSendButtonState = _textInputView.text.length>0? NO:YES;
    if (newSendButtonState != lastSendButtonState) {
        [self changeSendButton:newSendButtonState];
        lastSendButtonState = newSendButtonState;
    }
   
    _messageHoldLabel.hidden = _textInputView.text.length>0;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //文本消息结束编辑
     _messageHoldLabel.hidden = _textInputView.text.length>0;
    originalHeight = 0;
}

#pragma mark add picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self openCamera];
    }else if (buttonIndex == 1)
        [self openPhotoLibrary];
}

- (void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]&&self.superController) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self .superController presentViewController:picker animated:YES completion:nil];
    }
}

- (void)openPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]&&self.superController) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.superController presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.superController dismissViewControllerAnimated:YES completion:^{
        [self.delegate sendPicMessage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.superController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resizeAccordingToTextViewHeightChangedBy:(float)height
{
    //根据文本信息调整ui
    if (height>80) {
        return;
    }else
    {
        CGRect textViewFrame = _textInputView.frame;
        CGRect inputViewFrame = self.frame;
        CGFloat targetHeight = height+topBottom;
        
        CGFloat changedHeight = targetHeight - textViewFrame.size.height;
        textViewFrame.size.height = targetHeight;
        inputViewFrame.size.height = targetHeight+10;
        inputViewFrame.origin.y -= changedHeight;
            
        _textInputView.frame = textViewFrame;
        self.frame = inputViewFrame;
            
        [self.delegate heightOfTextViewChangedBy:changedHeight];
    }
}

@end







