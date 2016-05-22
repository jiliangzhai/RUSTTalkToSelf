//
//  baseView.h
//  ScreenLock
//
//  Created by rust_33 on 15/8/4.
//  Copyright (c) 2015年 rust_33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "touchView.h"

enum operation
{
    set,
    verify,
    modify
};

@interface baseView : UIView

@property(nonatomic,strong) NSMutableArray* rects;
@property(nonatomic) enum operation operation;
@property(nonatomic,weak) touchView* touchView;
@property(nonatomic)CGFloat radius;




@end
