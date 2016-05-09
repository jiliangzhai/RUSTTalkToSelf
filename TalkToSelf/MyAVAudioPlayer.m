//
//  MyAVAudioPlayer.m
//  TalkToSelf
//
//  Created by rust_33 on 16/1/27.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyAVAudioPlayer.h"

@interface MyAVAudioPlayer ()<AVAudioPlayerDelegate>

@end

@implementation MyAVAudioPlayer

 + (MyAVAudioPlayer *)sharedPlayer
{
    static MyAVAudioPlayer *sharedPlayer = nil;
    static dispatch_once_t once;
        
    dispatch_once(&once, ^{
            
        sharedPlayer = [[self alloc] init];
            
    });
    
    return sharedPlayer;
}

- (void)playWithData:(NSData *)voiceData
{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:voiceData error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    _player.delegate = self;
    [_player play];
    [self.delegate PlayerStartToPlayVoice];
}

- (void)playWithUrl:(NSString *)url
{
    dispatch_async(dispatch_queue_create("playSoundFromUrl", NULL), ^{
        [self.delegate PlayerStartToLoadData];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playWithData:data];
        });
    });
}

- (void)stopPlay
{
    if (_player && _player.isPlaying) {
        [_player stop];
    }
}

#pragma delegete
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate playerDidFinishPlay];
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    [self.delegate playerDidFinishPlay];
}
@end
