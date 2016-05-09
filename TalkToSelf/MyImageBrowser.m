//
//  MyImageBrowser.m
//  TalkToSelf
//
//  Created by rust_33 on 16/5/5.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import "MyImageBrowser.h"

static UIImageView *presentedImageView;
@implementation MyImageBrowser

+ (void)presentImageView:(UIImageView *)imageView
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    CGRect location = [imageView convertRect:imageView.bounds toView:bgView];
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:location];
    newImageView.image = imageView.image;
    newImageView.contentMode = UIViewContentModeScaleAspectFit;
    newImageView.clipsToBounds = YES;
    newImageView.tag = 1;
    
    presentedImageView = imageView;
    presentedImageView.alpha = 0.0;
    
    [bgView addSubview:newImageView];
    [keyWindow addSubview:bgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    [bgView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        newImageView.frame = bgView.bounds;
    }];
}

+ (void)hideImageView:(UITapGestureRecognizer *)tap
{
    UIView *bgView = [tap view];
    UIImageView *imageView = (UIImageView *)[bgView viewWithTag:1];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = [presentedImageView convertRect:presentedImageView.bounds toView:bgView];
    } completion:^(BOOL finished) {
        presentedImageView.alpha = 1.0;
        [bgView removeFromSuperview];
    }];
}

@end

