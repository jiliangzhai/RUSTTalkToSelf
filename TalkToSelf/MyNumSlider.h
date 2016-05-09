//
//  MyNumSlider.h
//  TalkToSelf
//
//  Created by rust_33 on 16/4/20.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNumSlider : UIView

- (instancetype)initWithFrame:(CGRect)frame size:(int)size color:(UIColor *)color;
- (void)slideToNum:(NSUInteger)num;

@end
