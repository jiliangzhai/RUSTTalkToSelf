//
//  MyTableViewCell.m
//  TalkToSelf
//
//  Created by rust_33 on 16/1/26.
//  Copyright © 2016年 rust_33. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "MyTableViewCell.h"
#import "MyMessageButton.h"
#import "MyMessage.h"
#import "MyCellFrame.h"
#import "MyAVAudioPlayer.h"
#import "MyImageBrowser.h"
#import "NSDate+Utils.h"

@interface MyTableViewCell ()<MYAVAudioPlayerDelegate>{
    
    UIView *thumbnailBgView;
    MyMessage *message;
    NSData *voiceData;
    BOOL voiceIsPlaying;
    NSString *localizedTime;
}

@end

@implementation MyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        
        thumbnailBgView = [[UIView alloc] init];
        thumbnailBgView.layer.cornerRadius = 25;
        thumbnailBgView.layer.masksToBounds = YES;
        thumbnailBgView.backgroundColor = [UIColor grayColor];
        _thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _thumbnailButton.layer.cornerRadius = 25;
        _thumbnailButton.layer.masksToBounds = YES;
        [_thumbnailButton addTarget:self action:@selector(thumbnailClicked:) forControlEvents:UIControlEventTouchUpInside];
        //[_thumbnailButton addTarget:self action:@selector(thumbnailDragedOutside:) forControlEvents:UIControlEventTouchUpOutside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_thumbnailButton addGestureRecognizer:longPress];
        
        _userName = [[UILabel alloc] init];
        _userName.textColor = [UIColor grayColor];
        _userName.font = [UIFont systemFontOfSize:11];
        
        _contentButton = [[MyMessageButton alloc] initWithFrame:CGRectZero];
        [_contentButton addTarget:self action:@selector(contentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *contentPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnContent:)];
        [_contentButton addGestureRecognizer:contentPress];
        
        [self.contentView addSubview:_timeLabel];
        [thumbnailBgView addSubview:_thumbnailButton];
        [self.contentView addSubview:thumbnailBgView];
        [self.contentView addSubview:_contentButton];
        [self.contentView addSubview:_userName];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceProximityDidChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    voiceIsPlaying = NO;
    return self;
}

//点击头像
- (void)thumbnailClicked:(UIButton *)sender
{
    [self.delegate thumbnailClickedWithMessageOriation:self.oriation];
}

//长按头像
- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [longPress locationInView:self.window];
        [self.delegate thumbnailLongPressedAtLocation:location messageOriation:self.oriation];
    }
}

//消息内容点击
- (void)contentButtonClicked:(UIButton *)sender
{
    if (_cellFrame.message.messageType == VoiceMessage) {
        
        if (!voiceIsPlaying) {
            voiceIsPlaying = YES;
            MyAVAudioPlayer *player = [MyAVAudioPlayer sharedPlayer];
            player.delegate = self;
            [player playWithData:voiceData];
        }else
            [self playerDidFinishPlay];
        
    }else if (_cellFrame.message.messageType == PicMessage)
    {
        [MyImageBrowser presentImageView:_contentButton.picImageView];
    }
}

//长按消息内容
- (void)longPressOnContent:(UILongPressGestureRecognizer *)press
{
    [self becomeFirstResponder];
    
    UIMenuController *controller = [UIMenuController sharedMenuController];
    
    UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(copyText:)];
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMessage:)];
    
    if (_cellFrame.message.messageType == TextMessage) {
        controller.menuItems = @[item1,item2];
    }else
    {
        controller.menuItems = @[item2];
    }
    [controller setTargetRect:self.contentButton.frame inView:self.contentButton.superview];
    [controller setMenuVisible:YES animated:YES];
}

- (void)PlayerStartToLoadData
{
    //加载语音
    [_contentButton beginLoadVoice];
}

- (void)PlayerStartToPlayVoice
{
    //播放语音
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [_contentButton didLoadVoice];
}

- (void)playerDidFinishPlay
{
    //播放完成
    voiceIsPlaying = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [_contentButton stopVoicePlay];
    [[MyAVAudioPlayer sharedPlayer] stopPlay];
}

- (void)setCellFrame:(MyCellFrame *)cellFrame
{
    //根据cellFrame决定cell的内容布局
    _cellFrame = cellFrame;
    message = cellFrame.message;
    self.oriation = message.messageOriation;
    
    localizedTime = [self localizedCreatedTime:message.createdTime];
    _timeLabel.text = localizedTime;
    _timeLabel.frame = cellFrame.timeLabelFrame;
    _timeLabel.hidden = !message.showTimeLabel;
    
    _thumbnailButton.frame = CGRectMake(0, 0, 50, 50);
    [_thumbnailButton setBackgroundImage:message.thumbnail forState:UIControlStateNormal];
    thumbnailBgView.frame = cellFrame.thumbnailFrame;
    thumbnailBgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    thumbnailBgView.layer.borderWidth = 2.0;
    
    _userName.text = message.userName;
    _userName.textAlignment = NSTextAlignmentCenter;
    _userName.frame = cellFrame.userNameFrame;
    
    _contentButton.frame = cellFrame.contentFrame;
    _contentButton.picImageView.hidden = YES;
    _contentButton.voiceView.hidden = YES;
    [_contentButton setTitle:@"" forState:UIControlStateNormal];
    if (message.messageOriation == isFormSelf)
        [_contentButton setIsFormSelf:YES];
    else
        [_contentButton setIsFormSelf:NO];
    
    switch (message.messageType) {
        case 0:
            [_contentButton setTitle:message.textMessage forState:UIControlStateNormal];
            break;
        case 1:
            _contentButton.picImageView.hidden = NO;
            _contentButton.picImageView.frame = _contentButton.bounds;
            _contentButton.picImageView.image = message.picMessage;
            [self maskView:_contentButton.picImageView withImage:_contentButton.bgImage];
            break;
        case 2:
            _contentButton.voiceView.hidden = NO;
            _contentButton.voiceDuration.text = [NSString stringWithFormat:@"%li's voice",(long)message.voiceDuration];
            voiceData = message.voiceMessage;
        default:
            break;
    }
}

- (void)maskView:(UIView *)targetView withImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = targetView.frame;
    targetView.layer.mask = imageView.layer;
}

- (void)deviceProximityDidChange:(NSNotificationCenter *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (NSString *)localizedCreatedTime:(NSString *)createdTime
{
    NSString *subString = [createdTime substringWithRange:NSMakeRange(0, 19)];
    NSDate *lastDate = [NSDate dateFromString:subString withFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //NSInteger interval = [zone secondsFromGMTForDate:lastDate];
    //lastDate = [lastDate dateByAddingTimeInterval:interval];
    
    NSString *dateStr;
    NSString *period;
    NSString *hour;
    
    if ([lastDate year]==[[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {
            dateStr = [lastDate stringYearMonthDayCompareToday];
        }else{
            dateStr = [lastDate stringMonthDay];
        }
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }//有可能是错误的，找个十二点测试一下
    
    
    if ([lastDate hour]>=5 && [lastDate hour]<12) {
        period = @"早上";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
        period = @"下午";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
        period = @"晚上";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else{
        period = @"凌晨";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }
    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
    
}

#pragma menuController
- (BOOL)canBecomeFirstResponder
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
    pateBoard.string = self.cellFrame.message.textMessage;
}

- (void)deleteMessage:(id)sender
{
    [self.delegate deleteCell:self];
}
@end











