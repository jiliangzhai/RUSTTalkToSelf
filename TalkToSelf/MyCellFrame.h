//
//  MyCellFrame.h
//  TalkToSelf
//
//  Created by rust_33 on 16/5/6.
//  Copyright © 2016年 rust_33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MyMessage;

@interface MyCellFrame : NSObject

@property(nonatomic,strong)MyMessage *message;
@property(nonatomic)CGRect timeLabelFrame;
@property(nonatomic)CGRect thumbnailFrame;
@property(nonatomic)CGRect userNameFrame;
@property(nonatomic)CGRect contentFrame;
@property(nonatomic)CGFloat cellHeight;

- (instancetype)initWithMessage:(MyMessage *)message;

@end

