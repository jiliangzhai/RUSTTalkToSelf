//
//  MyRecordProgressView.m
//  TalkToSelf
//
//  Created by rust_33 on 16/2/17.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyRecordProgressView.h"

@interface MyRecordProgressView (){
    
    NSTimer *timer;
    float second;
    NSInteger angel;
    NSString *finishStr;
}
@property(nonatomic,strong) UIWindow *layoutWindow;
@end

@implementation MyRecordProgressView

@synthesize layoutWindow;

+ (MyRecordProgressView *)sharedProgress
{
    static dispatch_once_t once;
    static MyRecordProgressView *sharedProgressView;
    
    if (!sharedProgressView) {
        dispatch_once(&once, ^{
            sharedProgressView = [[MyRecordProgressView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            sharedProgressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        });
    }
    return sharedProgressView;
}

+ (void)start
{
    [[MyRecordProgressView sharedProgress] showProgress];
}

- (void)showProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        second = 0;
        angel = 0;
        
        CGPoint location = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetHeight([UIScreen mainScreen].bounds)/2);
        _clockPanel = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        _clockPanel.image = [UIImage imageNamed:@"clockPanelNew.png"];
        _clockPanel.center = location;
        _duration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
        _duration.center = location;
        _duration.textAlignment = NSTextAlignmentCenter;
        _duration.textColor = [[UIColor yellowColor] colorWithAlphaComponent:1.0];
        _duration.font = [UIFont systemFontOfSize:24];
        _duration.text = @"开始录音";
        [self addSubview:_clockPanel];
        [self addSubview:_duration];
        [self.layoutWindow addSubview:self];
        
        if (timer) {
            [timer invalidate];
            timer = nil;
        };
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(animationBegin) userInfo:nil repeats:YES];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    });
}

+ (void)stopWithSuccess
{
    [[MyRecordProgressView sharedProgress] removeProgressWithStr:@" "];
}

+ (void)stopWithTooLongRecorder
{
    [[MyRecordProgressView sharedProgress] removeProgressWithStr:@"太长啦！"];
}

+ (void)stopWithTooShortRecorder
{
    [[MyRecordProgressView sharedProgress] removeProgressWithStr:@"太短啦！"];
}

+ (void)stopWithRecprderCanceled
{
    [[MyRecordProgressView sharedProgress] removeProgressWithStr:@"取消录音"];
}

- (void)animationBegin
{
    second += 0.1;
    angel += 15;
    _duration.text = [NSString stringWithFormat:@"%.1f'S",second];
    _clockPanel.transform = CGAffineTransformMakeRotation(angel*(M_PI/180));
}

- (void) removeProgressWithStr:(NSString *)str
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [timer invalidate];
        timer = nil;
        
        finishStr = str;
        if (![finishStr isEqualToString:@" "]) {
            
            [_clockPanel removeFromSuperview];
            _clockPanel = nil;
            
            _duration.font = [UIFont systemFontOfSize:20];
            _duration.textColor = [UIColor yellowColor];
            _duration.text = str;
            
            [UIView animateWithDuration:0.2 animations:^{
                 _duration.transform = CGAffineTransformMakeScale(2.0, 2.0);
            } completion:^(BOOL finished) {
                 _duration.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
            [UIView animateWithDuration:0.6 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                
                [_duration removeFromSuperview];
                _duration = nil;
                
                NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                [windows removeObject:layoutWindow];
                layoutWindow= nil;
                
                [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                    if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                        [window makeKeyWindow];
                        *stop = YES;
                    }
                }];
            }];
        }else
        {
            [UIView animateWithDuration:1.0 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                
                
                [_duration removeFromSuperview];
                [_clockPanel removeFromSuperview];
                _duration = nil;
                _clockPanel = nil;
                
                NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                [windows removeObject:layoutWindow];
                layoutWindow= nil;
                
                [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                    if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                        [window makeKeyWindow];
                        *stop = YES;
                    }
                }];
            }];
        }
        
    });
}

- (UIWindow *)layoutWindow
{
    if (!layoutWindow) {
        layoutWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        layoutWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        layoutWindow.userInteractionEnabled = NO;
        [layoutWindow makeKeyAndVisible];
    }
    return layoutWindow;
}
@end






