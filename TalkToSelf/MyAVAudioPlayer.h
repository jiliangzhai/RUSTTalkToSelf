//
//  MyAVAudioPlayer.h
//  TalkToSelf
//
//  Created by rust_33 on 16/1/27.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol MYAVAudioPlayerDelegate <NSObject>

- (void)PlayerStartToLoadData;
- (void)PlayerStartToPlayVoice;
- (void)playerDidFinishPlay;

@end

@interface MyAVAudioPlayer : NSObject

@property(nonatomic,strong) AVAudioPlayer *player;
@property(nonatomic,strong) id<MYAVAudioPlayerDelegate> delegate;

+ (MyAVAudioPlayer *)sharedPlayer;
- (void)playWithUrl:(NSString *)url;
- (void)playWithData:(NSData *)voiceData;
- (void)stopPlay;

@end
