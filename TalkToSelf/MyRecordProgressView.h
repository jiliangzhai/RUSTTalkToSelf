//
//  MyRecordProgressView.h
//  TalkToSelf
//
//  Created by rust_33 on 16/2/17.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyRecordProgressView : UIView

@property(nonatomic,strong) UIImageView *clockPanel;
@property(nonatomic,strong) UILabel *duration;

+ (void)start;
+ (void)stopWithSuccess;
+ (void)stopWithTooLongRecorder;
+ (void)stopWithTooShortRecorder;
+ (void)stopWithRecprderCanceled;

@end
