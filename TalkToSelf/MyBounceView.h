//
//  MyBounceView.h
//  RUSTBounceView
//
//  Created by rust_33 on 16/4/15.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BallRadius 30.0f


@interface MyBounceView : UIView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image startLocation:(CGPoint)location;

@end
